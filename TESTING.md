# Cafaye Testing Framework

Cafaye uses a tiered testing architecture designed for speed, reliability, and comprehensive verification. All tests are unified under the `caf-test` entry point.

## Testing Architecture

We categorize tests into distinct layers to avoid the "100 VMs" problem:

### Layer 0 & 1: Unit & Logic (Fast)
*   **System:** Runs directly on the host (Linux/macOS).
*   **Engine:** [BATS-core](https://github.com/bats-core/bats-core) for bash, Nix evaluation for Nix code.
*   **Scope:** Shell script logic, JSON state manipulation, and module logic in isolation.
*   **Location:** `tests/unit/`
*   **Speed:** Seconds

### Layer 2 & 3: Integration & System (Comprehensive)
*   **System:** Runs inside a NixOS VM using QEMU.
*   **Engine:** NixOS Testing Framework (Python driver).
*   **Scope:** Kernel boot, systemd services, networking, and full stack integration (Rails, Docker, multi-module scenarios).
*   **Location:** `tests/core/`, `tests/cli/`, `tests/modules/`, `tests/integration/`
*   **Speed:** Minutes

### Layer 4: Real-World Tests (Final Validation)
*   **System:** Actual VPS provisioning.
*   **Scope:** Fresh Ubuntu/macOS installation, full user workflows, backup/restore.
*   **Location:** `tests/integration/real-world/`
*   **Speed:** Hours
*   **Frequency:** Before releases, not every commit

---

## Usage

The `caf-test` script is the unified entry point for all tests.

### Commands

```bash
# --- Unit Tests (Logic & State) ---
caf-test unit                            # Run all unit tests locally
caf-test unit tests/unit/cli/state.bats  # Run a specific unit test file
caf-test unit --remote                   # Run on remote forge

# --- Integration Tests (VMs) ---
caf-test integration                     # Run all integration tests
caf-test integration core                # Test core functionality
caf-test integration modules-ruby        # Test specific module

# --- Real-World Tests (VPS) ---
caf-test real-world                      # Full VPS provisioning tests

# --- Shortcut Suites ---
caf-test lint           # Static analysis only (fastest)
caf-test core           # Core integration tests
caf-test modules        # All module tests
caf-test all            # Everything (slow)
```

### Local vs. Remote

Run tests locally for fast feedback, or on the remote forge for comprehensive testing:

```bash
# Append --remote to run on the forge
caf-test unit --remote
caf-test integration core --remote
caf-test real-world --remote
```

---

## Test Directory Structure

```text
tests/
├── unit/                    # BATS tests (Local, fast)
│   ├── cli/                 # CLI logic tests
│   ├── lib/                 # Library function tests
│   └── installer/           # Installer logic tests
│
├── core/                    # Core system tests
│   └── unified.nix          # Boot, Network, basic services
│
├── modules/                 # Module tests
│   ├── languages/           # Language runtime tests
│   ├── services/            # Service tests
│   └── unified.nix          # All modules combined
│
├── cli/                     # CLI integration tests
│   └── unified.nix          # CLI tool verification
│
└── integration/             # Integration scenarios
    ├── stacks/              # Full stack tests (Rails, Django, etc.)
    ├── security/            # Security tests
    └── real-world/          # Actual VPS tests
```

---

## Debugging

### Interactive VM Debugging

If an integration test fails, run it in interactive mode:

```bash
caf-test integration core --debug
```

**In the interactive shell:**
*   `test_script()`: Run the test logic once.
*   `machine.shell()`: Open a root shell inside the VM.
*   `machine.succeed("command")`: Run commands manually.

### State Validation

Cafaye uses strict JSON schema validation. Test it:

```bash
# This should fail (wrong type)
caf-state-write core.tailscale_enabled "maybe"

# This should pass
caf-state-write core.tailscale_enabled true
```

Manual validation:
```bash
nix shell nixpkgs#check-jsonschema --command check-jsonschema \
  --schemafile user/user-state.schema.json \
  user/user-state.json
```

---

## GCP High-Performance Forge

For comprehensive testing with hardware acceleration (KVM).

### Setup

**Requirements:**
*   **Machine Type:** `n2-standard-8` (8 vCPUs, 32GB RAM)
*   **Disk:** 200GB Balanced PD
*   **OS:** Ubuntu 24.04 LTS
*   **Nested Virtualization:** Must be enabled

### Auto-Shutdown

The forge has an auto-shutdown script (`/usr/local/bin/caf-autoshutdown`) that terminates the instance after 1 hour of inactivity (no SSH sessions, low CPU). This preserves credits.

### Running Remote Tests

```bash
# SSH into the forge
ssh user@<FORGE_IP>

# Sync and run
cd ~/cafaye-dev
git pull origin master
caf-test all
```

---

## Troubleshooting

### KVM & Hardware Acceleration

Integration tests require KVM for acceptable speeds.

**GCP Forge:** Ensure Nested Virtualization is enabled in instance settings.

**Local Linux:** Ensure `/dev/kvm` is accessible:
```bash
sudo usermod -aG kvm $USER
# Log out and back in
```

### Missing Nix

The `caf-test` script will prompt to install Nix if not found. This is non-destructive.

### Test Timeouts

If tests timeout:
- Check available RAM (need 4GB+ free)
- Check disk space (need 20GB+ free)
- Try running specific tests instead of `all`

---

## Writing Tests

### Unit Test Example (BATS)

```bash
#!/usr/bin/env bats
# tests/unit/cli/state.bats

@test "state write updates JSON" {
  run caf-state-write languages.ruby true
  [ "$status" -eq 0 ]
  
  run jq -r '.languages.ruby' user/user-state.json
  [ "$output" = "true" ]
}
```

### Integration Test Example (Nix)

```nix
# tests/modules/languages/ruby.nix
{ pkgs, ... }:

pkgs.testers.runNixOSTest {
  name = "ruby-module";
  
  nodes.machine = { ... }: {
    imports = [ ../../modules/languages/ruby.nix ];
    
    _module.args.userState = {
      languages.ruby = true;
    };
  };
  
  testScript = ''
    machine.wait_for_unit("default.target")
    
    # Test Ruby is installed
    machine.succeed("which ruby")
    machine.succeed("ruby --version | grep '3.3'")
    
    # Test gems work
    machine.succeed("gem list")
    
    print("✓ Ruby module tests passed")
  '';
}
```

### Real-World Test Example (Bash)

```bash
#!/usr/bin/env bash
# tests/integration/real-world/vps-install.sh

set -e

VPS_IP="${1:-}"

echo "Testing VPS installation on $VPS_IP"

# Run installer
ssh root@$VPS_IP "curl -fsSL https://cafaye.sh | bash"

# Verify installation
ssh root@$VPS_IP "which caf"
ssh root@$VPS_IP "which zellij"
ssh root@$VPS_IP "ruby --version"

echo "✓ VPS installation test passed"
```

---

## Test Checklist

Before submitting a PR:

- [ ] `./bin/test.sh` passes locally
- [ ] New features have tests
- [ ] Tests cover both success and failure cases
- [ ] Documentation updated if needed
- [ ] Commit messages are clear

For major changes:
- [ ] `caf-test integration --remote` passes
- [ ] `caf-test real-world --remote` passes (if applicable)
