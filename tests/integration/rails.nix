{ pkgs, inputs, userState, ... }:

{
  name = "integration-rails";
  nodes = {
    machine = { ... }:
      {
        imports = [
          ../../core/boot.nix
          ../../core/hardware.nix
          ../../core/network.nix
          ../../core/security.nix
          ../../core/sops.nix
          ../../core/user.nix
          ../../modules
          ../../interface
          inputs.sops-nix.nixosModules.sops
        ];
        _module.args = {
          inherit inputs;
          userState = userState // {
            services = (userState.services or { }) // { postgresql = true; redis = true; };
            frameworks = (userState.frameworks or { }) // { rails = true; };
            languages = (userState.languages or { }) // { ruby = true; nodejs = true; };
          };
        };

        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    
    # Ensure services are up
    # Note: If they rely on userState configuration, ensure userState has them enabled.
    # By default, modules/services/redis.nix checks userState.services.redis.enable.
    # If defaults are true, they should be up. If false, we might need to override config.
    
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-default.service")

    # Verify Ruby Environment
    machine.succeed("ruby -v")
    machine.succeed("gem env")

    # Verify Node Environment
    machine.succeed("node -v")
    machine.succeed("npm -v")

    # Verify Database Connectivity
    machine.succeed("sudo -u postgres psql -c 'SELECT version();'")
    
    # Verify Redis Connectivity
    machine.succeed("redis-cli ping | grep PONG")

    # Integration: Create and Query DB
    machine.succeed("sudo -u postgres createdb rails_integration_test")
    machine.succeed("sudo -u postgres psql -d rails_integration_test -c 'CREATE TABLE widgets (id serial PRIMARY KEY, name varchar(255));'")
    machine.succeed("sudo -u postgres psql -d rails_integration_test -c \"INSERT INTO widgets (name) VALUES ('Test Widget');\"")
    machine.succeed("sudo -u postgres psql -d rails_integration_test -c 'SELECT name FROM widgets;' | grep 'Test Widget'")
  '';
}
