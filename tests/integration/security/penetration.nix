{ pkgs, inputs, userState, ... }:

{
  name = "security-penetration";
  nodes = {
    victim = { ... }: {
      imports = [ 
         ../../../core/security
         ../../../core/network.nix
         ../../../core/hardware.nix
         ../../../core/user.nix
         ../../../core/sops.nix
         inputs.sops-nix.nixosModules.sops
      ];
      # Mock secrets
      sops.validateSopsFiles = false;
      systemd.services.tailscale-autoconnect.enable = false;
      
      # Ensure SSH is configured for keys only
      services.openssh.settings.PasswordAuthentication = false;
    };
    attacker = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.nmap pkgs.netcat-gnu pkgs.sshpass ];
    };
  };

  testScript = ''
    start_all()
    victim.wait_for_unit("sshd.service")
    attacker.wait_for_unit("multi-user.target")

    # 1. Port Scan: Check if ports are open on internal network
    # SSH (22) should be OPEN
    attacker.succeed("nc -z victim 22")
    
    # Web ports (80, 443) should be CLOSED (since no web server is running yet)
    attacker.fail("nc -z victim 80")
    attacker.fail("nc -z victim 443")

    # 2. SSH Password Auth Fail
    # Try to ssh with password 'password' for root / cafaye. Should fail.
    attacker.fail("sshpass -p 'password' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no root@victim 'echo pwned'")
    attacker.fail("sshpass -p 'password' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no cafaye@victim 'echo pwned'")

    # 3. Nmap Scan (Optional - heavy)
    # attacker.succeed("nmap -p 1-1000 victim | grep '22/tcp open'")
  '';
}
