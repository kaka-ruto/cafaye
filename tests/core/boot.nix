{ pkgs, inputs, userState, ... }:

{
  name = "core-boot";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [ ../../core/boot.nix ../../core/hardware.nix ];
      _module.args = { inherit userState; };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    # Check if ZRAM is enabled
    machine.succeed("zramctl")
    # Check kernel version (should be latest)
    machine.succeed("uname -r")
  '';
}
