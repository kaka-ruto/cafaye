{ pkgs, inputs, userState, ... }:

{
  name = "core-security-sudo";
  nodes = {
    machine = { ... }: {
      imports = [ 
        ../../../core/security/sudo.nix
        ../../../core/boot.nix
        ../../../core/hardware.nix
        ../../../core/user.nix
      ];
      _module.args = { inherit inputs userState; };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    
    # Ensure sudo works
    machine.succeed("sudo --version")
    
    # Verify sudo hardening settings in the config file
    machine.succeed("grep 'Defaults use_pty' /etc/sudoers")
  '';
}
