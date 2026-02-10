# Cafaye OS Testing Framework

Cafaye OS uses a tiered testing architecture designed for speed, reliability, and comprehensive system verification. The framework is unified under a single entry point: `cli/scripts/caf-test`.

## 🏗 Architecture: The Test Pyramid

To avoid the "100 VMs" problem, we categorize tests into distinct layers:

### Layer 0 & 1: Unit & Logic (Fast)
*   **System**: Runs directly on the host (Linux/macOS).
*   **Engine**: [BATS-core](https://github.com/bats-core/bats-core).
*   **Scope**: Shell script logic, JSON state manipulation, and TUI wizard flows (via mocking).
*   **Location**: `tests/unit/`

### Layer 2 & 3: Integration & System (Comprehensive)
*   **System**: Runs inside a NixOS VM using QEMU.
*   **Engine**: NixOS Testing Framework (Python driver).
*   **Scope**: Kernel boot, systemd services, networking, and full stack integration (Rails, Docker, etc.).
*   **Location**: `tests/core/`, `tests/cli/`, `tests/modules/`, `tests/integration/`

---

## 🛠 Usage

The `caf-test` script is the unified entry point for all tests. It automatically handles dependency bootstrapping (BATS, Nix).

### Local vs. Remote Workflow
Cafaye OS is designed for a **remote-first** development cycle. You can run tests locally on your Mac, or offload them to the **GCP Forge** for maximum speed.

```bash
# Append --remote to ANY command to run it on the Forge
caf-test unit --remote
caf-test integration core-boot --remote
```

### Basic Commands
```bash
# --- Unit Tests (Logic & State) ---
caf-test unit                            # Run all unit tests locally
caf-test unit tests/unit/cli/state.bats  # Run a specific unit test file
caf-test unit --remote                   # Run all unit tests on the Forge

# --- Integration Tests (NixOS VMs) ---
caf-test integration                     # Run all unified integration tests
caf-test integration core-boot           # Run a specific check (e.g., boot logic)
caf-test integration modules-languages   # Test language installations

# --- Shortcut Suites ---
caf-test core          # Run 'core-unified' (Fast system verify)
caf-test modules       # Run 'modules-unified' (Verify all dev tools)
caf-test all           # Run EVERYTHING (Unit + Core)
```

---

## 🐞 Debugging & Reliability

### 1. Interactive VM Debugging
If an integration test is failing, you can launch it in **Interactive Mode**. This boots the VM and gives you a Python shell to control it.

```bash
caf-test integration core-boot --debug
```
**In the shell:**
*   `test_script()`: Runs the entire test logic once.
*   `machine.shell()`: Opens a real root shell inside the running NixOS VM.
*   `machine.succeed("systemctl status tailscaled")`: Run commands manually.

### 2. State Validation (The Guard)
Cafaye OS uses a strict JSON schema for its state. The `caf-state-write` script automatically validates any change against `user/user-state.schema.json`.

*   **Test this**: Try running `caf-state-write core.tailscale_enabled "maybe"`. It will be rejected because it expects a boolean.
*   **Manual Check**: `nix shell nixpkgs#check-jsonschema --command check-jsonschema --schemafile user/user-state.schema.json user/user-state.json`

### 3. Granular Targeting
Avoid running the entire OS suite if you're only working on one module. We have "forced-state" targets for common modules:

```bash
caf-test integration modules-ruby      # Only tests Ruby installation
caf-test integration modules-rust      # Only tests Rust
caf-test integration modules-postgres  # Only tests PostgreSQL
```

---

## ☁️ GCP High-Performance Forge

For comprehensive integration testing with hardware acceleration (KVM), we use a dedicated **GCP Forge**.

### 1. Creation Checklist
Create an instance in GCP with the following specs:
*   **Machine Type**: `n2-standard-8` (8 vCPUs, 32GB RAM).
*   **Disk**: 200GB Balanced PD.
*   **OS**: Ubuntu 24.04 LTS.
*   **Crucial**: Enable **Nested Virtualization** (found under *Advanced Configuration -> CPU Platform and Customization*).

### 2. Auto-Shutdown (Credit Saver)
The Forge is equipped with an auto-shutdown script (`/usr/local/bin/caf-autoshutdown`) that terminates the instance if it has been idle for 1 hour (no SSH sessions and low CPU load). This ensures your $300 credits last for months.

### 3. Running Remote Tests
1.  **SSH into the Forge**: Use your local `cafaye` key.
    ```bash
    ssh kaka@<GCP_IP>
    ```
2.  **Sync & Run**:
    ```bash
    cd ~/cafaye-dev
    git pull origin master
    caf-test all
    ```

---

## 🔧 Troubleshooting

### KVM & Hardware Acceleration
Cafaye OS integration tests require **KVM (Hardware Acceleration)** to run at acceptable speeds.
*   **GCP Forge**: Ensure **Nested Virtualization** is enabled in the instance settings.
*   **Local Linux**: Ensure `/dev/kvm` is accessible to your user.

### Missing Nix
The `caf-test` script will prompt to install the **Determinate Nix Installer** if it doesn't find `nix` in your PATH. This is a non-destructive multi-user install.
