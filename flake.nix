{
  description = "Cafaye OS: The cloud-native developer powerhouse";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      userState = builtins.fromJSON (builtins.readFile ./user/user-state.json);
    in
    {
      nixosConfigurations.cafaye-vps = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs userState; };
        modules = [
          ./core
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          gum
          sops
          age
        ];
        shellHook = ''
          echo "☕ Cafaye OS Development Shell"
        '';
      };

      # CI checks and tests
      checks.${system} = {
        core-boot = pkgs.testers.runNixOSTest (import ./tests/core/boot.nix { inherit pkgs inputs userState; });
        core-network = pkgs.testers.runNixOSTest (import ./tests/core/network.nix { inherit pkgs inputs userState; });
        core-security = pkgs.testers.runNixOSTest (import ./tests/core/security.nix { inherit pkgs inputs userState; });
      };
    };
}
