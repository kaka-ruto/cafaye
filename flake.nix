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

      # Function to read user state with priority: local -> example
      # Absolute etcPath is avoided during pure evaluation to prevent host contamination
      readUserState = repoPath: 
        let
          localPath = repoPath + "/user/user-state.json";
          examplePath = repoPath + "/user/user-state.json.example";
        in
          if builtins.pathExists localPath then builtins.fromJSON (builtins.readFile localPath)
          else builtins.fromJSON (builtins.readFile examplePath);

      userState = readUserState ./.;

      # Supported systems for development shells
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Standard test runner
        runTest = testFile: pkgs.testers.runNixOSTest (import testFile { inherit pkgs inputs userState; });
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gum
            sops
            age
            check-jsonschema
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
            core-security = runTest ./tests/integration/security/default.nix;
            core-security-ssh = runTest ./tests/integration/security/ssh.nix;
            core-security-kernel = runTest ./tests/integration/security/kernel.nix;
            core-security-firewall = runTest ./tests/integration/security/firewall.nix;
            core-security-sudo = runTest ./tests/integration/security/sudo.nix;
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

            # Granular checks with forced states
            modules-ruby = pkgs.testers.runNixOSTest (import ./tests/modules/languages.nix { 
              inherit pkgs inputs; 
              userState = userState // { languages = { ruby = true; }; }; 
            });
            modules-rust = pkgs.testers.runNixOSTest (import ./tests/modules/languages.nix { 
              inherit pkgs inputs; 
              userState = userState // { languages = { rust = true; }; }; 
            });
            modules-nodejs = pkgs.testers.runNixOSTest (import ./tests/modules/languages.nix { 
              inherit pkgs inputs; 
              userState = userState // { languages = { nodejs = true; }; }; 
            });
            modules-postgres = pkgs.testers.runNixOSTest (import ./tests/modules/services.nix { 
              inherit pkgs inputs; 
              userState = userState // { services = { postgresql = true; }; }; 
            });
            integration-security-penetration = runTest ./tests/integration/security/penetration.nix;
            integration-app-deployment = runTest ./tests/integration/app-deployment.nix;
            integration-rails = runTest ./tests/integration/rails.nix;
            integration-dev-ux = runTest ./tests/integration/dev-ux.nix;
            interface-workload-aliases = runTest ./tests/interface/workload-aliases.nix;
            integration-installer-kexec = runTest ./tests/integration/installer/kexec.nix;
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
      nixosModules.cafaye = ./default.nix;

      # NixOS configuration generator for different architectures
      nixosConfigurations.cafaye = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # Default to x86_64
        specialArgs = { inherit inputs userState; };
        modules = [
          self.nixosModules.cafaye
        ];
      };
    };
}
