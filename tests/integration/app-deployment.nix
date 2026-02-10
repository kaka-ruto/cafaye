{ pkgs, inputs, userState, ... }:

{
  name = "app-deployment-rails";
  nodes = {
    machine = { ... }: {
      imports = [ 
        ../../core/boot.nix
        ../../core/hardware.nix
        ../../core/network.nix
        ../../core/security
        ../../core/sops.nix
        ../../core/user.nix
        inputs.sops-nix.nixosModules.sops
        ../../modules
      ];
      _module.args = { 
        inherit inputs; 
        userState = userState // { 
          frameworks = { rails = true; }; 
          services = { postgresql = true; redis = true; };
          languages = { ruby = true; nodejs = true; };
        }; 
      };

      # Mock secrets
      sops.validateSopsFiles = false;
      systemd.services.tailscale-autoconnect.enable = false;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    
    # Check Rails and Node installation
    machine.succeed("rails --version")
    machine.succeed("node --version")
    machine.succeed("sqlite3 --version")
    
    # Initialize a new Rails app
    machine.succeed("sudo -u cafaye bash -c 'cd ~ && rails new myapp --database=postgresql --skip-bundle'")
    
    # Ensure Postgres and Redis are up
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-default.service")
    machine.succeed("sudo -u cafaye psql -c 'select 1' cafaye")
    machine.succeed("redis-cli ping | grep PONG")
    
    # Check if files were created
    machine.succeed("test -d /home/cafaye/myapp")
    machine.succeed("test -f /home/cafaye/myapp/config/database.yml")
    
    # Test SQLite path
    machine.succeed("sudo -u cafaye bash -c 'cd ~ && rails new sqliteapp --database=sqlite3 --skip-bundle'")
    machine.succeed("test -d /home/cafaye/sqliteapp")
  '';
}
