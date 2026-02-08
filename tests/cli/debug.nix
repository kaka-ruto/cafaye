{ pkgs, inputs, userState, ... }:

{
  name = "cli-debug";
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
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Test debug scripts are available
    machine.succeed("which caf-debug-collect")
    machine.succeed("which caf-debug-upload")
    machine.succeed("which caf-debug-view")
    
    # Test debug collect with print mode (no interactive prompts)
    machine.succeed("caf-debug-collect --no-sudo --print | head -20")
    
    # Verify log file was created
    machine.succeed("test -f /tmp/cafaye-debug.log")
  '';
}
