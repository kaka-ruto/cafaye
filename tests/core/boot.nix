{ pkgs, inputs, userState, ... }:

{
  name = "core-boot";
  nodes = {
    machine = { config, lib, modulesPath, ... }: {
      imports = [ 
        ../../core/boot.nix 
        ../../core/hardware.nix 
        ../../core/user.nix
      ];
      _module.args = { inherit userState; };
      
      # The boot module already configures GRUB from userState
      # We just verify the system boots successfully in the testScript
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
