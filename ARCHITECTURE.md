# 🏗️ Cafaye OS: Architectural Blueprint

Cafaye OS is built using a **Vertical Layering** strategy. Instead of building horizontal features, we build complete "stacks" of functionality that are independently testable and verifiable. This ensures that the foundation is rock-solid before we build the user-facing developer experience on top.

---

## 층 (Layers) Overview

### 🧱 Layer 0: The Bootstrap (Foundation)
**Goal:** Transform a raw Linux VPS into a bootable, NixOS-powered Cafaye instance.

- **Components:**
    - `install.sh`: The one-liner bootstrap script.
    - `hardware/vps.nix`: Disk partitioning via `disko` (GPT/EFI).
    - `core/boot.nix`: GRUB, ZRAM, and Kernel optimizations.
- **How to Build:**
    - Run `curl install.sh | bash` on a fresh Debian/Ubuntu VPS.
- **How to Test:**
    - **Fast Test:** `nix-build .#individualChecks.x86_64-linux.core-boot`
    - **Success Criteria:** The system reboots, partitions are correctly mounted (`/`, `/boot`), and the SSH daemon is listening.
- **Integration:** Provides the physical/virtual filesystem and boot environment for all upper layers.
- **Testing:**
    - Use `caf-test installer` to verify the bootstrap logic and TUI wizard.
    - Tests run on the VPS in a persistent directory (`~/cafaye-dev`) to allow rapid iteration.

---

### ⚙️ Layer 1: The Orchestration (State & CLI)
**Goal:** Provide a "No-Nix" user experience where configuration is managed via a familiar TUI.

- **Components:**
    - `user/state.json`: The single source of truth for user choices (moved to `/etc/cafaye/state.json`).
    - `cli/`: The `caf` command-line interface (built with `gum`).
    - `caf-apply`: The bridge that triggers Nix rebuilds based on JSON changes.
- **How to Build:**
    - The `cli` package is defined in `cli/package.nix` and included in `environment.systemPackages`.
- **How to Test:**
    - **Step-by-Step:**
        1. Run `caf-state-write "languages.rust" "true"`.
        2. Run `caf-system-rebuild`.
        3. Run `rustc --version`.
    - **Success Criteria:** JSON modifications are atomical, and rebuilds correctly reflect those choices in the system environment.
- **Integration:** Reads from Layer 0 (filesystem) and provides variables for Layer 3 (Workloads).

---

### 🛡️ Layer 2: Hardening (Security & Connectivity)
**Goal:** Implement "Zero-Trust" SSH and encrypted secrets management.

- **Components:**
    - `core/security.nix`: Firewall rules (close all public ports).
    - `core/network.nix`: Tailscale mesh integration.
    - `core/sops.nix`: Secrets encryption via `sops-nix`.
- **How to Build:**
    - Tailscale is enabled by default via `user-state.json`.
- **How to Test:**
    - **External Test:** Attempt `ssh root@<public-ip>` (Should Timeout/Refuse).
    - **Internal Test:** `ssh root@<tailscale-ip>` (Should Succeed).
    - **Secrets Test:** `caf-secrets set OPENAI_KEY '...'` followed by verifying the node can decrypt it.
- **Integration:** Wraps Layer 1 and 0 in a secure tunnel.

---

### 🚀 Layer 3: The Workload (Developer Experience)
**Goal:** Deliver the "Omarchy Vibe" — beautiful, pre-configured dev tools.

- **Components:**
    - `modules/languages/`: Ruby, Python, Go, Rust.
    - `modules/frameworks/`: Rails, Django, Next.js.
    - `interface/terminal/`: Zellij, Starship, Zsh themes.
- **How to Build:**
    - Each module is a conditional NixOS import based on `userState`.
- **How to Test:**
    - **Unit Tests:** `nix-build .#checks.x86_64-linux.modules-unified`.
    - **Functional Test:** Spin up a Rails server and verify it's accessible over the Tailscale sidecar.
- **Integration:** The final "Product" layer that the user actually interacts with for their daily work.

---

## ⛓️ Inter-Layer Communication Map

1.  **User Input** (`caf` CLI) -> Writes to `/etc/cafaye/state.json`.
2.  **System Rebuild** (`caf apply`) -> Triggers `nixos-rebuild switch --flake .#cafaye`.
3.  **Nix Evaluation** (`flake.nix`) -> Reads `state.json` -> Imports relevant `modules/`.
4.  **Hardware Application** (`disko` / `boot.nix`) -> Ensures the underlying VPS matches the config.

---

## 🧪 Testing Philosophy

1.  **Local (macOS):** Syntax checking and "Dry Run" evaluations using `nix-instantiate`.
2.  **VPS (CI/CD):** 
    - Full VM integration tests using `nixos-test`.
    - Real-world "Factory" builds where a fresh VPS is provisioned and checked.
3.  **The "Live Mirror":** Every `module/` must have a corresponding `tests/` file that maps 1:1.

---

## 🛠 Hardware Abstraction (Architecture)

To ensure Cafaye runs on both **Intel (x86_64)** and **Apple/Graviton (aarch64)**:
- All modules must be architecture-agnostic.
- `flake.nix` uses `flake-utils.lib.eachSystem` to generate packages for both.
- The `nixosConfigurations` entrypoint detects the hardware during the `install.sh` phase.
