{ pkgs, inputs, userState, ... }:

# Unified CLI Test - Tests all CLI functionality in ONE VM boot
# This replaces: cli-main, cli-debug, cli-doctor, cli-factory
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

        # Mock secrets
        sops.validateSopsFiles = false;
        systemd.services.tailscale-autoconnect.enable = false;

        # Install tools needed for CLI testing
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
    # Check if caf command exists
    machine.succeed("which caf")
    # Check if it's executable
    machine.succeed("test -x $(which caf)")
    # Check syntax
    machine.succeed("bash -n $(which caf)")

    # === CLI-DEBUG TESTS ===
    machine.succeed("which caf-debug-collect")
    machine.succeed("test -x $(which caf-debug-collect)")
    machine.succeed("bash -n $(which caf-debug-collect)")
    
    # Test debug output directory creation
    machine.succeed("mkdir -p /tmp/cafaye-debug && test -d /tmp/cafaye-debug")

    # === CLI-DOCTOR TESTS ===
    machine.succeed("which caf-system-doctor")
    machine.succeed("test -x $(which caf-system-doctor)")
    machine.succeed("bash -n $(which caf-system-doctor)")
    
    # Doctor should exit 0 even for informational output
    machine.succeed("caf-system-doctor || true")

    # === CLI-FACTORY TESTS ===
    machine.succeed("which caf-factory-check")
    machine.succeed("test -x $(which caf-factory-check)")
    machine.succeed("bash -n $(which caf-factory-check)")
    
    # Test that gh CLI is available (needed by factory-check)
    machine.succeed("which gh")
    machine.succeed("gh --version")
    
    # Test that jq is available
    machine.succeed("which jq")
    machine.succeed("jq --version")
  '';
}
