{
  description = "Cafaye: The first Development Runtime built for collaboration between humans and AI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
    let
      # Library for helper functions
      lib = nixpkgs.lib;

      # Function to read user state from split config files
      readUserState = repoPath: 
        let
          envPath = repoPath + "/environment.json";
          settingsPath = repoPath + "/settings.json";
          examplePath = repoPath + "/user/user-state.json.example";
          
          env = if builtins.pathExists envPath then builtins.fromJSON (builtins.readFile envPath) else {};
          settings = if builtins.pathExists settingsPath then builtins.fromJSON (builtins.readFile settingsPath) else {};
          example = if builtins.pathExists examplePath then builtins.fromJSON (builtins.readFile examplePath) else {};
        in
          # Priority: environment/settings > example
          lib.recursiveUpdate example (lib.recursiveUpdate settings env);

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        userState = readUserState ./.;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gum
            jq
            git
          ];
          shellHook = ''
            echo "☕ Cafaye Development Shell"
          '';
        };

        checks = let
          isDerivation = x: builtins.isAttrs x && x ? type && x.type == "derivation";
          isFunction = builtins.isFunction;
          isAttrs = builtins.isAttrs;

          # Helper to recursively find .nix files and create a flat attrset of tests
          findTests = baseDir: relPath:
            let
              fullPath = baseDir + "/${relPath}";
              items = builtins.readDir fullPath;
              
              # Process each item in the directory
              processItem = name: type:
                let 
                  currentRelPath = if relPath == "" then name else "${relPath}/${name}";
                  currentAttrName = if relPath == "" then name else "${lib.replaceStrings ["/"] ["."] relPath}.${name}";
                in
                if type == "directory" then
                  if name == "fixtures" || name == "lib" then {} 
                  else findTests baseDir currentRelPath
                else if type == "regular" && lib.hasSuffix ".nix" name 
                        && name != "test-helper.nix" # Exclude helpers
                then
                  let 
                    testName = lib.removeSuffix ".nix" currentAttrName;
                    imported = import (baseDir + "/${currentRelPath}");
                    
                    # Case 1: Direct Derivation (e.g. runNixOSTest)
                    # We try calling it with standard args if it's a function
                    result = if isFunction imported then 
                               let call = (imported { inherit pkgs inputs lib; }); in
                               if isDerivation call then call else null
                             else if isDerivation imported then imported
                             else null;

                    # Case 2: Functional Module (HM module function)
                    isModule = isFunction imported && result == null;

                    # Case 3: Pure Data (attrset)
                    isData = isAttrs imported && result == null;
                  in
                  { "${testName}" = 
                    if result != null then result
                    else (inputs.home-manager.lib.homeManagerConfiguration {
                      inherit pkgs;
                      modules = [
                        ./home.nix
                        ./tests/test-helper.nix
                      ] ++ (if isModule then [ imported ] else []);
                      extraSpecialArgs = { 
                        inherit inputs; 
                        userState = if isData then imported else {};
                      };
                    }).activationPackage;
                  }
                else
                  {};
                  
              # Merge all processed items into one attrset
              mergedItems = lib.foldl' (acc: item: acc // (processItem item.name item.type)) {} 
                (map (name: { inherit name; type = builtins.getAttr name items; }) (builtins.attrNames items));
            in
            mergedItems;

          # Discover ALL tests automatically
          allTests = findTests ./tests "";

          # Create suites based on top-level directories in tests/
          topDirs = builtins.attrNames (lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./tests));
          
          suites = lib.genAttrs topDirs (dir:
            pkgs.linkFarm "cafaye-suite-${dir}" (
              lib.mapAttrsToList (name: drv: { inherit name; path = drv; }) 
                (lib.filterAttrs (n: v: lib.hasPrefix "${dir}." n) allTests)
            )
          );

          # Shorthand for CLI
          shorthandSuites = {
             modules = suites.modules or {};
             languages = lib.filterAttrs (n: v: lib.hasPrefix "modules.languages." n) allTests;
             editors = lib.filterAttrs (n: v: lib.hasPrefix "modules.editors." n) allTests;
             services = lib.filterAttrs (n: v: lib.hasPrefix "modules.services." n) allTests;
             interface = lib.filterAttrs (n: v: lib.hasPrefix "modules.interface." n) allTests;
             installer = suites.installer or {};
          };

          # Aggregate EVERYTHING
          all-modules = pkgs.linkFarm "all-cafaye-modules" (
            lib.mapAttrsToList (name: drv: { inherit name; path = drv; }) allTests
          );
        in 
          allTests // suites // shorthandSuites // { inherit all-modules; };

        # Helper to generate a configuration for a specific user
        # Usage: nix run .#homeConfigurations.YOUR_SYSTEM.YOUR_USER.activationPackage
      }
    ) // {
      # Home Manager configurations generator
      # For simplicity, we can provide a function or use a standard naming convention
      homeConfigurations = {
        # Default configuration for the installer
        # The installer will likely use `nix build .#homeConfigurations.default.activationPackage`
        # and we need to make it work for the current system.
        # However, flakes are usually static. 
        # So we define common ones.
        "x86_64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./home.nix { home.backupFileExtension = "backup"; } ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
        "aarch64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          modules = [ ./home.nix { home.backupFileExtension = "backup"; } ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
        "x86_64-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-darwin";
          modules = [ ./home.nix { home.backupFileExtension = "backup"; } ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
        "aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          modules = [ ./home.nix { home.backupFileExtension = "backup"; } ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
      };
    };
}
