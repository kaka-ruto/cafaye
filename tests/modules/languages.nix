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
        _module.args = {
          inherit inputs;
          userState = userState // {
            languages = {
              rust = true;
              go = true;
              nodejs = true;
              python = true;
              ruby = true;
            };
          };
        };

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Test Rust
    machine.succeed("rustup --version")

    # Test Go
    machine.succeed("go version")

    # Test Node.js
    machine.succeed("node --version")
    machine.succeed("npm --version")

    # Test Python
    machine.succeed("python3 --version")
    machine.succeed("pip --version")

    # Test Ruby
    machine.succeed("ruby --version")
    machine.succeed("bundle --version")

    # Test Docker (service should be running)
    machine.wait_for_unit("docker.service")
    machine.succeed("docker --version")
  '';
}
