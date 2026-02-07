{
  description = "Cafaye OS: The cloud-native developer powerhouse";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
          core-boot = pkgs.testers.runNixOSTest (import ./tests/core/boot.nix { inherit pkgs inputs userState; });
          core-network = pkgs.testers.runNixOSTest (import ./tests/core/network.nix { inherit pkgs inputs userState; });
          core-security = pkgs.testers.runNixOSTest (import ./tests/core/security.nix { inherit pkgs inputs userState; });
        };
      }
    ) // {
      # NixOS configuration for the VPS (stays outside eachSystem)
      nixosConfigurations.cafaye-vps = nixpkgs.lib.nixosSystem {
        system = vpsSystem;
        specialArgs = { inherit inputs userState; };
        modules = [
          ./core
        ];
      };
    };
}
