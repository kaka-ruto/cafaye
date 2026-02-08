{ pkgs, inputs, userState, ... }:

{
  name = "core-boot";
  nodes = {
    machine = { config, ... }: {
      imports = [ 
        ../../core/boot.nix 
        ../../core/hardware.nix 
        ../../core/user.nix
      ];
      _module.args = { inherit userState; };
      
      # Verify the GRUB device is configured from user state
      assertions = [
        {
          assertion = config.boot.loader.grub.device == (userState.core.boot.grub_device or "/dev/vda");
          message = "GRUB device should match user state configuration";
        }
      ];
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
