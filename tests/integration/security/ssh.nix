{ pkgs, inputs, userState, ... }:

{
  name = "core-security-ssh";
  nodes = {
    machine = { ... }: {
      imports = [ 
        ../../../core/security/ssh.nix 
        ../../../core/hardware.nix
        ../../../core/user.nix
      ];
      _module.args = { 
        inherit inputs;
        userState = userState // { core = userState.core // { security = { bootstrap_mode = true; }; }; };
      };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("sshd.service")
    # Verify hardened SSH config exists
    machine.succeed("grep 'KexAlgorithms curve25519-sha256' /etc/ssh/sshd_config")
    # Verify password auth is off
    machine.succeed("grep 'PasswordAuthentication no' /etc/ssh/sshd_config")
  '';
}
