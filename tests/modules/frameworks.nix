{ pkgs, inputs, userState, ... }:

let
  # Enable all frameworks for testing
  testState = userState // {
    frameworks = {
      rails = true;
      django = true;
      nextjs = true;
    };
  };
in
{
  name = "modules-frameworks";
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

    # Test Rails (should enable Ruby + Postgres)
    machine.succeed("ruby --version")
    machine.wait_for_unit("postgresql.service")
    machine.succeed("vips --version")

    # Test Django (should enable Python + Postgres)
    machine.succeed("python3 --version")
    machine.succeed("sqlite3 --version")

    # Test Next.js (should enable Node)
    machine.succeed("node --version")
  '';
}
