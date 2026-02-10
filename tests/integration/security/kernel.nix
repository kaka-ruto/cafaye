{ pkgs, inputs, userState, ... }:

{
  name = "core-security-kernel";
  nodes = {
    machine = { ... }: {
      imports = [ 
        ../../../core/boot.nix 
        ../../../core/security/kernel.nix
        ../../../core/hardware.nix
      ];
      _module.args = { inherit userState; };
    };
  };

  testScript = ''
    machine.start()
    # Verify ASLR and Pointer protection
    machine.succeed("sysctl kernel.kptr_restrict | grep '2'")
    machine.succeed("sysctl kernel.randomize_va_space | grep '2'")
  '';
}
