{ pkgs, inputs, userState, ... }:

{
  name = "cli-doctor";
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

    # Test doctor script is available
    machine.succeed("which caf-system-doctor")
    
    # Run doctor (should complete without error)
    machine.succeed("caf-system-doctor")
    
    # Test version utilities
    machine.succeed("which caf-version")
    machine.succeed("which caf-version-pkgs")
    
    # Test about utility
    machine.succeed("which caf-about-show")
  '';
}
