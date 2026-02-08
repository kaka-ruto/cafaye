{ pkgs, inputs, userState, ... }:

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
        _module.args = { inherit inputs userState; };

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    ${pkgs.lib.optionalString (userState.frameworks.rails or false) ''
      # Test Rails (should enable Ruby + Postgres)
      machine.succeed("ruby --version")
      machine.wait_for_unit("postgresql.service")
      machine.succeed("vips --version")
    ''}

    ${pkgs.lib.optionalString (userState.frameworks.django or false) ''
      # Test Django (should enable Python + Postgres)
      machine.succeed("python3 --version")
      machine.succeed("sqlite3 --version")
    ''}

    ${pkgs.lib.optionalString (userState.frameworks.nextjs or false) ''
      # Test Next.js (should enable Node)
      machine.succeed("node --version")
    ''}
  '';
}
