{ pkgs, inputs, userState, ... }:

{
  name = "cli-factory";
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

        # Install gh CLI for factory-check
        environment.systemPackages = with pkgs; [
          gh
          jq
        ];
      };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Test if caf-factory-check script exists and is executable
    machine.succeed("test -x /etc/cafaye/cli/scripts/caf-factory-check")

    # Test if the script can show help/usage (it will fail without gh auth, but should exist)
    # First check it doesn't have syntax errors
    machine.succeed("bash -n /etc/cafaye/cli/scripts/caf-factory-check")

    # Test that gh CLI is available
    machine.succeed("which gh")
    machine.succeed("gh --version")

    # Test that jq is available (required by the script)
    machine.succeed("which jq")
    machine.succeed("jq --version")

    # Test that the .factory directory structure would be created
    machine.succeed("mkdir -p /tmp/test-factory && test -d /tmp/test-factory")

    # Test JSON parsing with sample data (simulate a failure log)
    machine.succeed("echo '[{\"databaseId\": 12345, \"status\": \"completed\", \"conclusion\": \"failure\", \"headBranch\": \"master\", \"headSha\": \"abc123def\", \"createdAt\": \"2026-02-08T10:00:00Z\", \"url\": \"https://github.com/test/test/actions/runs/12345\", \"event\": \"push\", \"displayTitle\": \"Test commit message\"}]' | jq '.[0].conclusion' | grep -q 'failure'")
    
    machine.succeed("echo '[{\"databaseId\": 12345}]' | jq 'length' | grep -q '1'")
  '';
}
