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

        checks = {
          # Languages
          ruby-module = (import ./tests/modules/languages/ruby.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          python-module = (import ./tests/modules/languages/python.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          nodejs-module = (import ./tests/modules/languages/nodejs.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          rust-module = (import ./tests/modules/languages/rust.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          go-module = (import ./tests/modules/languages/go.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;

          # Editors
          neovim-module = (import ./tests/modules/editors/neovim.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          helix-module = (import ./tests/modules/editors/helix.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;

          # Services
          postgresql-module = (import ./tests/modules/services/postgresql.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          redis-module = (import ./tests/modules/services/redis.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;

          # Interface
          tools-module = (import ./tests/modules/interface/tools.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
          zellij-module = (import ./tests/modules/interface/terminal/zellij.nix { inherit pkgs inputs; home-module = ./home.nix; }).activationPackage;
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
