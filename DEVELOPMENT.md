# 🧪 Cafaye OS: Verification Matrix & Testing Protocol

This document serves as the **Source of Truth** for system stability. Every feature in Cafaye OS must map to a specific automated test. We do not rely on manual testing.

## 🏆 The Quality Gate Philosophy

Every code change must pass this rigorous testing hierarchy before merging:

| Level | Name | Tool | Purpose | Status |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Static Analysis** | `caf-test lint` | Syntax, secrets, Nix correctness. Fails fast. | ✅ Verified |
| **2** | **Logic Verification** | `caf-test unit` | CLI behavior, state management (BATS). No VMs. | ✅ Verified |
| **3** | **System Integration** | `core-unified` | Boot, kernel, network, essential services. | ✅ Checked |
| **4** | **Adversarial Testing** | `security-penetration` | "Sad path" verification (port scans, brute force). | ⬜ Pending |
| **5** | **Real-World Usage** | `app-deployment` | "Happy path" user simulation (deploying apps). | ✅ Verified |

---

## ✅ Feature Verification Matrix

### 🛡️ Core Layer (Immutable Base)
The foundation of the OS. If this fails, nothing runs.

| Feature | Status | Verified By | Test File |
| :--- | :---: | :--- | :--- |
| **Kernel Hardening** | ✅ Checked | `core-security` | `tests/integration/security/default.nix` |
| **SSH Configuration** | ✅ Checked | `core-security` | `tests/integration/security/ssh.nix` |
| **SSH Brute Force Block** | ⬜ | `security-penetration` | `tests/integration/security/penetration.nix` |
| **Firewall (Default Block)** | ⬜ | `security-penetration` | `tests/integration/security/penetration.nix` |
| **Tailscale Networking** | ✅ | `core-unified` | `tests/core/unified.nix` |
| **ZRAM Swap** | ✅ | `core-unified` | `tests/core/unified.nix` |

### 🧩 Modules Layer (The LEGO Blocks)
Language runtimes and backing services.

| Feature | Status | Verified By | Test File |
| :--- | :---: | :--- | :--- |
| **PostgreSQL Service** | ✅ | `modules-unified` | `tests/modules/unified.nix` |
| **Redis Service** | ✅ | `modules-unified` | `tests/modules/unified.nix` |
| **Ruby Runtime** | ✅ | `modules-unified` | `tests/modules/unified.nix` |
| **Python Runtime** | ⬜ | `modules-unified` | `tests/modules/unified.nix` |
| **Node.js Runtime** | ✅ | `modules-unified` | `tests/modules/unified.nix` |
| **Rust / Go Runtimes** | ⬜ | `modules-unified` | `tests/modules/unified.nix` |
| **Rails Stack** | ✅ | `app-deployment` | `tests/integration/app-deployment.nix` |
| **Docker Engine** | ⬜ | `installer-wizard` | `tests/unit/installer/wizard.bats` |

### 🖥️ Interface & CLI Layer
The user experience and management tools.

| Feature | Status | Verified By | Test File |
| :--- | :---: | :--- | :--- |
| **CLI Tools (`caf`)** | ✅ | `cli-unified` | `tests/cli/unified.nix` |
| **System Doctor** | ✅ | `cli-unified` | `tests/cli/unified.nix` |
| **Debug Collector** | ✅ | `cli-unified` | `tests/cli/unified.nix` |
| **Zellij / Terminal** | ✅ | `modules-unified` | `tests/modules/unified.nix` |
| **Fastfetch** | ✅ | `modules-unified` | `tests/modules/unified.nix` |
| **Installer Logic** | ✅ | `installer-wizard` | `tests/unit/installer/wizard.bats` |

---

## 🛠 Developer Workflow

### 1. Fast Feedback Loop (Local)
Run these frequently while developing. They take seconds.

```bash
# Check syntax and secrets
./cli/scripts/caf-test lint

# Verify logic changes (e.g., installer script)
./cli/scripts/caf-test unit
```

### 2. Deep Verification (Remote Forge)
Run this before submitting a PR. It spins up VMs on the remote forge.

```bash
# Run ALL tests (Lint -> Unit -> Integration -> Penetration)
./cli/scripts/caf-test all --remote --no-cleanup
```

### 3. Debugging Specific Components
If `caf-test all` fails, isolate the component:

```bash
# Debug just the security layer
./cli/scripts/caf-test security --remote

# Debug just the CLI tools
./cli/scripts/caf-test cli-integration --remote
```

---

## 📂 Test Directory Structure

```text
tests/
├── unit/                 # BATS tests (Local logic)
│   └── installer/        # Installer wizard logic
│   └── cli/              # State management logic
├── core/                 # Core system integration
│   └── unified.nix       # Boot, Network, ZRAM
├── modules/              # Software stack integration
│   └── unified.nix       # Languages, Services, Editors
├── cli/                  # CLI tool integration
│   └── unified.nix       # caf, caf-debug, caf-doctor
└── integration/          # Complex scenarios
    ├── security/         # Security specific
    │   ├── penetration.nix # Attacker vs Victim
    │   └── default.nix     # Hardening checks
    └── app-deployment.nix # Real-world Rails deploy
```
