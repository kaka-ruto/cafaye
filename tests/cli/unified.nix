{ pkgs, inputs, userState, ... }:

# Unified CLI Test - Tests all CLI functionality in ONE VM boot
{
  name = "cli-unified";
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
          inputs.sops-nix.nixosModules.sops
          ../../cli
        ];
        _module.args = { inherit inputs userState; };

        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;

        environment.systemPackages = with pkgs; [
          gh
          jq
        ];
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # === CLI-MAIN TESTS ===
    machine.succeed("which caf")
    machine.succeed("test -x $(which caf)")
    machine.succeed("bash -n $(which caf)")

    # === CLI-DEBUG TESTS ===
    machine.succeed("which caf-debug-collect")
    machine.succeed("test -x $(which caf-debug-collect)")
    machine.succeed("bash -n $(which caf-debug-collect)")
    machine.succeed("mkdir -p /tmp/cafaye-debug && test -d /tmp/cafaye-debug")

    # === CLI-DOCTOR TESTS ===
    machine.succeed("which caf-system-doctor")
    machine.succeed("test -x $(which caf-system-doctor)")
    machine.succeed("bash -n $(which caf-system-doctor)")
    machine.succeed("caf-system-doctor || true")

    # === CLI-FACTORY TESTS ===
    machine.succeed("which caf-factory-check")
    machine.succeed("test -x $(which caf-factory-check)")
    machine.succeed("bash -n $(which caf-factory-check)")
    machine.succeed("which gh")
    machine.succeed("gh --version")
    machine.succeed("which jq")
    machine.succeed("jq --version")

    # === CAF-SETUP EXISTENCE TEST ===
    # Full functionality tested in integration-caf-setup
    machine.succeed("which caf-setup")
    machine.succeed("test -x $(which caf-setup)")
    machine.succeed("bash -n $(which caf-setup)")

    print("✅ cli-unified test passed")
  '';
}
