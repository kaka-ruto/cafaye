{ pkgs, inputs, userState, ... }:

{
  name = "integration-first-run-wizard";
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
          ../../modules
          ../../interface
          ../../cli
          inputs.sops-nix.nixosModules.sops
        ];
        _module.args = { inherit inputs userState; };

        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
        
        # Mock git for the test
        environment.systemPackages = [ pkgs.git ];
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Setup mock repository structure
    machine.succeed("mkdir -p /home/kaka/Code/Cafaye/cafaye/user")
    machine.succeed("echo '{}' > /home/kaka/Code/Cafaye/cafaye/user/user-state.json")
    machine.succeed("chown -R kaka:users /home/kaka/Code")

    # Create mock bin directory
    machine.succeed("mkdir -p /tmp/bin")
    machine.succeed("echo '#!/bin/sh' > /tmp/bin/caf-system-update")
    machine.succeed("echo 'echo Mock Update' >> /tmp/bin/caf-system-update")
    machine.succeed("chmod +x /tmp/bin/caf-system-update")

    # Run caf-setup non-interactively with modified PATH
    # We su to kaka to test user permissions
    machine.succeed("su - kaka -c 'export PATH=/tmp/bin:$PATH; caf-setup --no-confirm --editor nvim --distro lazyvim --languages ruby,python'")

    # Verify user-state.json was updated
    # We check if ruby was enabled
    machine.succeed("grep 'ruby' /home/kaka/Code/Cafaye/cafaye/user/user-state.json")
  '';
}
