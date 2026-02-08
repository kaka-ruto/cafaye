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
            integration-setup = pkgs.testers.runNixOSTest (import ./tests/integration/setup.nix { inherit pkgs inputs userState; });
            integration-rails = pkgs.testers.runNixOSTest (import ./tests/integration/rails.nix { inherit pkgs inputs userState; });
          };
          
          # Individual tests for debugging (NOT run in default CI)
          # Run individually: nix build .#individualChecks.x86_64-linux.<name>
          # Useful for: debugging specific failures, faster iteration during development
          individualChecks = lib.optionalAttrs (system == vpsSystem) {
            core-boot = pkgs.testers.runNixOSTest (import ./tests/core/boot.nix { inherit pkgs inputs userState; });
            core-network = pkgs.testers.runNixOSTest (import ./tests/core/network.nix { inherit pkgs inputs userState; });
            core-security = pkgs.testers.runNixOSTest (import ./tests/core/security.nix { inherit pkgs inputs userState; });
            cli-main = pkgs.testers.runNixOSTest (import ./tests/cli/main.nix { inherit pkgs inputs userState; });
            cli-debug = pkgs.testers.runNixOSTest (import ./tests/cli/debug.nix { inherit pkgs inputs userState; });
            cli-doctor = pkgs.testers.runNixOSTest (import ./tests/cli/doctor.nix { inherit pkgs inputs userState; });
            cli-factory = pkgs.testers.runNixOSTest (import ./tests/cli/factory.nix { inherit pkgs inputs userState; });
            interface-terminal = pkgs.testers.runNixOSTest (import ./tests/interface/terminal.nix { inherit pkgs inputs userState; });
            modules-languages = pkgs.testers.runNixOSTest (import ./tests/modules/languages.nix { inherit pkgs inputs userState; });
            modules-services = pkgs.testers.runNixOSTest (import ./tests/modules/services.nix { inherit pkgs inputs userState; });
            modules-frameworks = pkgs.testers.runNixOSTest (import ./tests/modules/frameworks.nix { inherit pkgs inputs userState; });
            modules-editors = pkgs.testers.runNixOSTest (import ./tests/modules/editors.nix { inherit pkgs inputs userState; });
            modules-editors-distributions = pkgs.testers.runNixOSTest (import ./tests/modules/editors-distributions.nix { inherit pkgs inputs userState; });
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
