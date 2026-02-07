{ pkgs, inputs, userState, ... }:

{
  name = "core-network";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [ ../../core/network.nix ../../core/sops.nix ];
      _module.args = { inherit inputs userState; };
      
      # Mock the sops file presence
      sops.validateSopsFiles = false;
      # Provide a mock value for the secret path to avoid evaluation error
      systemd.services.tailscale-autoconnect.enable = false; # Disable in tests to avoid needing real keys
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
