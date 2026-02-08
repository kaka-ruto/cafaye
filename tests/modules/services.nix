{ pkgs, inputs, userState, ... }:

let
  # Enable services for testing
  testState = userState // {
    services = {
      postgresql = true;
      redis = true;
    };
  };
in
{
  name = "modules-services";
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
          ../..//modules/services
          inputs.sops-nix.nixosModules.sops
        ];
        _module.args = { inherit inputs; userState = testState; };

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Test PostgreSQL
    machine.wait_for_unit("postgresql.service")
    machine.succeed("sudo -u cafaye psql -c 'select 1' cafaye")

    # Test Redis
    machine.wait_for_unit("redis-default.service")
    machine.succeed("redis-cli ping | grep PONG")
  '';
}
