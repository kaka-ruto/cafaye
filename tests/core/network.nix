{ pkgs, inputs, userState, ... }:

{
  name = "core-network";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [ ../../core/network.nix ];
      _module.args = { inherit userState; };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    # Check if Tailscale is running
    machine.wait_for_unit("tailscaled.service")
    # Check hostname
    machine.succeed("hostname | grep cafaye")
  '';
}
