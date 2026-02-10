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
          ../../core/security
          ../../core/sops.nix
          ../../core/user.nix
          ../../modules
          ../../interface
          inputs.sops-nix.nixosModules.sops
        ];
        _module.args = {
          inherit inputs;
          userState = userState // {
            # Force enable required services for Rails stack testing
            services = (userState.services or { }) // { postgresql = true; redis = true; };
            frameworks = (userState.frameworks or { }) // { rails = true; };
            languages = (userState.languages or { }) // { ruby = true; };
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
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-default.service")

    # Verify Ruby Environment
    machine.succeed("ruby -v")
    machine.succeed("gem env")

    ${pkgs.lib.optionalString (userState.languages.nodejs or false) ''
      # Verify Node Environment
      machine.succeed("node -v")
      machine.succeed("npm -v")
    ''}

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
