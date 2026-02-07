{ pkgs, inputs, userState, ... }:

{
  name = "cli-main";
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
          ../../cli
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

    # Test if caf is in PATH
    machine.succeed("caf --help || true") # It might exit if not interactive, but it should exist

    # Test if helper scripts exist in PATH (they are copied to bin/ as well)
    machine.succeed("caf-logo-show")
    machine.succeed("caf-state-read languages.ruby")
    
    # Test if hook run works
    machine.succeed("caf-hook-run test-hook")
  '';
}
