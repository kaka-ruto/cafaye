{
  description = "Cafaye Kexec Installer Generator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, nixos-generators, ... }: {
    packages.x86_64-linux.default = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "kexec-bundle";  # Produces a self-extracting single-file runner
      specialArgs = { inherit disko; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
