{
  description = "Cafaye: The first Development Runtime built for collaboration between humans and AI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
    let
      # Library for helper functions
      lib = nixpkgs.lib;

      # Function to read user state with priority: environment.json -> user/user-state.json.example
      readUserState = repoPath: 
        let
          envPath = repoPath + "/environment.json";
          examplePath = repoPath + "/user/user-state.json.example";
        in
          if builtins.pathExists envPath then builtins.fromJSON (builtins.readFile envPath)
          else if builtins.pathExists examplePath then builtins.fromJSON (builtins.readFile examplePath)
          else {};

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

        checks = {
          # Evaluation tests for modules
          ruby-module = (import ./tests/modules/languages/ruby.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          tools-module = (import ./tests/modules/interface/tools.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
        };

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
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
        "aarch64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
        "x86_64-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-darwin";
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
        "aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit inputs; userState = readUserState ./.; };
        };
      };
    };
}
