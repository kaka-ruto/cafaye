{ pkgs, ... }:

{
  name = "integration-installer-kexec";
  skipTypeCheck = true;
  skipLint = true;
  
  nodes = {
    # This node represents the installer booting up
    machine = { config, pkgs, lib, ... }: {
      imports = [
        ../../../installer/kexec/installer-module.nix
      ];
      
      # Mock the destructive commands
      environment.systemPackages = [
        (pkgs.writeScriptBin "disko-install" ''
          #!/bin/sh
          echo "MOCK: disko-install $*"
          exit 0
        '')
        (pkgs.writeScriptBin "nixos-install" ''
          #!/bin/sh
          echo "MOCK: nixos-install $*"
          exit 0
        '')
        (pkgs.writeScriptBin "reboot" ''
          #!/bin/sh
          echo "MOCK: reboot"
          exit 0
        '')
      ];
      
      # Mock the user state file required by the configuration
      environment.etc."cafaye/user-state.json" = lib.mkForce {
        text = builtins.toJSON {
          core = {
            boot = { grub_device = "/dev/vda"; };
          };
        };
      };
      
      # For testing, we mock ping
      # Mock ping for the service execution (override the whole path list)
      systemd.services.cafaye-install.path = lib.mkForce [
        pkgs.bash
        pkgs.coreutils
        pkgs.util-linux
        pkgs.jq
        pkgs.openssh
        pkgs.nix
        pkgs.nixos-install-tools
        pkgs.iproute2
        # Mock git to avoid network
        (pkgs.writeScriptBin "git" ''
          #!/bin/sh
          if [ "$1" = "clone" ]; then
             echo "MOCK: git clone $2 $3"
             mkdir -p "$3"
             exit 0
          fi
          echo "MOCK: git $*"
        '')
        # Mock curl
        (pkgs.writeScriptBin "curl" ''
          #!/bin/sh
          echo "MOCK: curl $*"
          exit 0
        '')
        # Mock ping
        (pkgs.writeScriptBin "ping" ''
          #!/bin/sh
          echo "MOCK: ping success"
          exit 0
        '')
      ];

      # Mock git config so the script doesn't fail if git is called
      environment.etc."gitconfig".text = ''
        [user]
          email = "test@example.com"
          name = "Test User"
      '';
      
      # Disable network wait requirement for test speed
      systemd.services.cafaye-install.after = pkgs.lib.mkForce [];
      systemd.services.cafaye-install.wants = pkgs.lib.mkForce [];
    };
  };

  testScript = ''
    start_all()
    
    # The cafaye-install service should start automatically
    machine.wait_for_unit("cafaye-install.service")
    
    # Verify logs to see if our mocks were called
    logs = machine.succeed("journalctl -u cafaye-install.service")
    
    # Check for expected output
    assert "MOCK: disko-install" in logs or "MOCK: nixos-install" in logs
    assert "Installation SUCCESS!" in logs
  '';
}
