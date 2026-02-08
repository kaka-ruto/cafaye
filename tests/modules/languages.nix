{ pkgs, inputs, userState, ... }:

{
  name = "modules-languages";
  nodes = {
    machine = { ... }:
      {
        imports = [
          ../../core/boot.nix
          ../../core/hardware.nix
          ../../core/network.nix
          ../../core/security.nix
          ../../core/sops.nix
          ../../core/user.nix
          inputs.sops-nix.nixosModules.sops
          ../../modules
        ];
        _module.args = { inherit inputs userState; };

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    ${pkgs.lib.optionalString (userState.languages.rust or false) ''
      # Test Rust
      machine.succeed("rustup --version")
    ''}

    ${pkgs.lib.optionalString (userState.languages.go or false) ''
      # Test Go
      machine.succeed("go version")
    ''}

    ${pkgs.lib.optionalString (userState.languages.nodejs or false) ''
      # Test Node.js
      machine.succeed("node --version")
      machine.succeed("npm --version")
    ''}

    ${pkgs.lib.optionalString (userState.languages.python or false) ''
      # Test Python
      machine.succeed("python3 --version")
      machine.succeed("pip --version")
    ''}

    ${pkgs.lib.optionalString (userState.languages.ruby or false) ''
      # Test Ruby
      machine.succeed("ruby --version")
      machine.succeed("bundle --version")
    ''}

    # Test Docker (should always be up if dev_tools.docker enabled?)
    # Core system usually enables docker? No, dev_tools enabled it.
    ${pkgs.lib.optionalString (userState.dev_tools.docker or false) ''
      machine.wait_for_unit("docker.service")
      machine.succeed("docker --version")
    ''}
  '';
}
