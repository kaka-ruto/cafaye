{
  description = "Cafaye OS: The cloud-native developer powerhouse";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, sops-nix, flake-utils, ... }@inputs:
    let
      # Library for helper functions
      lib = nixpkgs.lib;

      # System for the VPS (stays x86_64-linux)
      vpsSystem = "x86_64-linux";
      
      # User state shared across configurations
      userState = builtins.fromJSON (builtins.readFile ./user/user-state.json);

      # Supported systems for development shells
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gum
            sops
            age
          ];
          shellHook = ''
            echo "☕ Cafaye OS Development Shell"
          '';
        };

        # Evaluation checks for the dev systems
        # Note: runNixOSTest only works on Linux, so we only add it there
        checks = lib.optionalAttrs (system == vpsSystem) {
           # Unified tests (FAST) - Run multiple scenarios in ONE VM boot
           core-unified = pkgs.testers.runNixOSTest (import ./tests/core/unified.nix { inherit pkgs inputs userState; });
           cli-unified = pkgs.testers.runNixOSTest (import ./tests/cli/unified.nix { inherit pkgs inputs userState; });
           modules-unified = pkgs.testers.runNixOSTest (import ./tests/modules/unified.nix { inherit pkgs inputs userState; });
           
           # Integration tests (kept separate as they test complex interactions)
           integration-first-run-wizard = pkgs.testers.runNixOSTest (import ./tests/integration/first-run-wizard.nix { inherit pkgs inputs userState; });
           integration-rails = pkgs.testers.runNixOSTest (import ./tests/integration/rails.nix { inherit pkgs inputs userState; });
           
           # Individual tests (for local debugging, not run in CI)
           # Individual tests are available via: nix build .#checks.x86_64-linux.<name>
           # but excluded from the default flake check to save time
         };

        packages = {
          default = pkgs.callPackage ./cli/package.nix { };

          dockerImage = pkgs.dockerTools.buildImage {
            name = "cafaye";
            tag = "latest";
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = [ 
                (pkgs.callPackage ./cli/package.nix { })
                pkgs.bashInteractive 
                pkgs.coreutils
                pkgs.git
                pkgs.gum
                pkgs.jq
                pkgs.fzf
                pkgs.ripgrep
                pkgs.bat
                pkgs.eza
                pkgs.zoxide
              ];
            };
            config = { 
              Cmd = [ "bash" ]; 
              Env = [ "PATH=/bin:/usr/bin" ];
            };
          };
        };

        apps = {
          debug-vm = {
            type = "app";
            program = "${self.nixosConfigurations.cafaye.config.system.build.vm}/bin/run-cafaye-vm";
          };
        };
      }
    ) // {
      # NixOS configuration for the VPS (stays outside eachSystem)
      nixosConfigurations.cafaye = nixpkgs.lib.nixosSystem {
        system = vpsSystem;
        specialArgs = { inherit inputs userState; };
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./core
          ./interface
          ./modules
          ./cli
        ];
      };
    };
}
