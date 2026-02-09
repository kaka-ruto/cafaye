{
  description = "Cafaye OS: The cloud-native developer powerhouse";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix, flake-utils, ... }@inputs:
    let
      # Library for helper functions
      lib = nixpkgs.lib;

      # Function to read user state with priority: /etc -> local -> example
      readUserState = path: 
        let
          etcPath = "/etc/cafaye/user-state.json";
          localPath = ./user/user-state.json;
          examplePath = ./user/user-state.json.example;
        in
          if builtins.pathExists etcPath then builtins.fromJSON (builtins.readFile etcPath)
          else if builtins.pathExists localPath then builtins.fromJSON (builtins.readFile localPath)
          else builtins.fromJSON (builtins.readFile examplePath);

      userState = readUserState ./.;

      # Supported systems for development shells
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Helper to run tests without requiring KVM (Using software emulation TCG)
        # This allows tests to run on standard VPS instances without nested virt.
        runTest = testFile: pkgs.testers.runNixOSTest {
          imports = [ (import testFile { inherit pkgs inputs userState; }) ];
          # Configure QEMU to use TCG
          defaults.virtualisation.qemu.options = [ "-accel tcg" ];
        };
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
         checks = lib.optionalAttrs pkgs.stdenv.isLinux {
            core-unified = runTest ./tests/core/unified.nix;
            cli-unified = runTest ./tests/cli/unified.nix;
            modules-unified = runTest ./tests/modules/unified.nix;
            
            integration-setup = runTest ./tests/integration/setup.nix;
            integration-rails = runTest ./tests/integration/rails.nix;
          };
          
          # Individual tests
          individualChecks = lib.optionalAttrs pkgs.stdenv.isLinux {
            core-boot = runTest ./tests/core/boot.nix;
            core-network = runTest ./tests/core/network.nix;
            core-security = runTest ./tests/core/security.nix;
            cli-main = runTest ./tests/cli/main.nix;
            cli-debug = runTest ./tests/cli/debug.nix;
            cli-doctor = runTest ./tests/cli/doctor.nix;
            cli-factory = runTest ./tests/cli/factory.nix;
            interface-terminal = runTest ./tests/interface/terminal.nix;
            modules-languages = runTest ./tests/modules/languages.nix;
            modules-services = runTest ./tests/modules/services.nix;
            modules-frameworks = runTest ./tests/modules/frameworks.nix;
            modules-editors = runTest ./tests/modules/editors.nix;
            modules-editors-distributions = runTest ./tests/modules/editors-distributions.nix;
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
      # NixOS configuration generator for different architectures
      nixosConfigurations.cafaye = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # Default to x86_64
        specialArgs = { inherit inputs userState; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          ./hardware/vps.nix
          ./core
          ./interface
          ./modules
          ./cli
        ];
      };
    };
}
