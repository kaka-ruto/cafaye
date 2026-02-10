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

The `caf-test` script is self-bootstrapping. It will automatically install BATS and Nix if they are missing.

### Basic Commands
```bash
# Run all unit tests
caf-test unit

# Run a specific unit test file
caf-test unit tests/unit/cli/state.bats

# Run all integration tests (Requires Nix + KVM/TCG)
caf-test integration

# Run a specific integration test target
caf-test integration core-boot

# Run EVERYTHING (Unit + Core Integration)
caf-test all
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
