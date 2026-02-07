{ pkgs, inputs, userState, ... }:

{
  name = "core-network";
  nodes = {
    machine = {
      imports = [ 
        ../../core/network.nix 
        ../../core/sops.nix
        # We must also include the sops module itself because core-sops depends on it
        inputs.sops-nix.nixosModules.sops
      ];
      
      # We provide userState and inputs via specialArgs to avoid recursion
      # Actually, just using them here (thanks to the closure) is fine
      # as long as we don't try to pull them from the node's own 'args'
      
      _module.args = { inherit userState inputs; };
      
      # Mock the sops file presence
      sops.validateSopsFiles = false;
      # Disable the autoconnect service that requires real keys
      systemd.services.tailscale-autoconnect.enable = false;
      
      # Workaround for CI "modules-shrunk" error
      hardware.enableAllHardware = true;
      boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_6_6;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    # Check if Tailscale service is running
    machine.wait_for_unit("tailscaled.service")
    # Check hostname
    machine.succeed("hostname | grep cafaye")
  '';
}
