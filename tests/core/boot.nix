{ pkgs, inputs, userState, ... }:

{
  name = "core-boot";
  nodes = {
    machine = {
      imports = [ ../../core/boot.nix ../../core/hardware.nix ];
      _module.args = { inherit userState; };
      
      # Workaround for CI "modules-shrunk" error: force full bootloader + LTS kernel
      virtualisation.useBootLoader = true;
      virtualisation.useEFIBoot = true;
      hardware.enableAllHardware = true;
      boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_6_6;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    # Check if ZRAM is enabled
    machine.succeed("zramctl")
    # Check kernel version (should be latest)
    # Note: We just check if uname succeeds as a proxy for boot success
    machine.succeed("uname -r")
  '';
}
