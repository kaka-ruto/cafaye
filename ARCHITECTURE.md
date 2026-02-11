# 🏗️ Cafaye: Architectural Blueprint

Cafaye is built using a **modular, layered architecture**. Each layer is independently testable, composable, and extensible. This ensures the foundation is rock-solid before building user-facing features on top.

---

## Architecture Layers

### Layer 0: Infrastructure (Foundation)
**Goal:** Provide the runtime environment on any supported system.

- **Components:**
    - `install.sh`: The one-liner bootstrap script.
    - `core/nix.nix`: Nix package manager installation and configuration.
    - `core/home-manager.nix`: Home Manager setup for user environments.
- **Supported Platforms:**
    - Ubuntu 22.04/24.04 LTS
    - macOS 14.0+
    - Debian 12
- **How to Test:**
    - **Fast Test:** `nix-build .#checks.x86_64-linux.installer`
    - **Success Criteria:** Nix installs, Home Manager activates, basic tools available.
- **Integration:** Provides the package management and user environment foundation.

---

### Layer 1: Core Runtime (State & Configuration)
**Goal:** Provide a declarative, reproducible user experience.

- **Components:**
    - `user/state.json`: User preferences and choices.
    - `home-manager/`: Home Manager configuration files.
    - `caf-apply`: Bridge that applies configuration changes.
- **How to Build:**
    - Home Manager configuration is generated from `user/state.json`.
- **How to Test:**
    - **Step-by-Step:**
        1. Edit `user/state.json` to enable Ruby.
        2. Run `caf apply`.
        3. Run `ruby --version`.
    - **Success Criteria:** Configuration changes apply atomically and correctly.
- **Integration:** Reads from Layer 0 and provides the base for Layer 2 modules.

---

### Layer 2: Modules (Building Blocks)
**Goal:** Provide composable, reusable functionality.

- **Components:**
    - `modules/languages/`: Ruby, Python, Node, Go, Rust.
    - `modules/frameworks/`: Rails, Django, Next.js templates.
    - `modules/services/`: PostgreSQL, Redis, Docker.
    - `modules/editors/`: Neovim, VS Code, Helix.
    - `modules/ai/`: Claude Code, Aider, Ollama, Codex support.
- **How to Build:**
    - Each module is a conditional Home Manager import based on `user/state.json`.
- **How to Test:**
    - **Unit Tests:** `nix-build .#checks.x86_64-linux.modules-languages-ruby`.
    - **Integration Test:** Enable multiple modules and verify they work together.
- **Integration:** Composable units that users mix and match.

---

### Layer 3: Interface (Developer Experience)
**Goal:** Deliver the beautiful, productive terminal experience.

- **Components:**
    - `interface/terminal/`: Zellij, Starship, Zsh, themes.
    - `cli/`: The `caf` command-line interface (TUI with gum).
- **How to Test:**
    - **Unit Tests:** CLI logic and state management.
    - **Integration Tests:** Full terminal environment verification.
- **Integration:** The final layer users interact with daily.

---

### Layer 4: AI Agent Runtime (Future)
**Goal:** Enable AI agents to work autonomously.

- **Components:**
    - `modules/agents/runtime.nix`: Agent sandbox and execution environment.
    - `modules/agents/orchestrator.nix`: Task scheduling and management.
- **Status:** Planned for Phase 2.

---

## Communication Flow

1.  **User Input** (`caf` CLI) → Updates `user/state.json`.
2.  **Generation** (`caf apply`) → Generates Home Manager config from state.
3.  **Evaluation** (Home Manager + Nix) → Builds user environment.
4.  **Activation** → New environment activated, old preserved for rollback.

---

## Testing Philosophy

1.  **Static Analysis:** Syntax checking and evaluation (instant).
2.  **Unit Tests:** Module logic in isolation (fast).
3.  **Integration Tests:** Full VM tests with NixOS (comprehensive).
4.  **Real-World Tests:** Actual VPS provisioning (final validation).

---

## Hardware Abstraction

Cafaye supports both **Intel (x86_64)** and **Apple Silicon (aarch64)**:
- All modules are architecture-agnostic where possible.
- Architecture-specific packages handled by Nix.
- Tested on both local machines and cloud VPS instances.

---

## Extensibility

**Adding a new module:**
```nix
# modules/languages/crystal.nix
{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.languages.crystal or false;
in
{
  meta = {
    name = "Crystal";
    description = "Crystal programming language";
    category = "languages";
  };
  
  config = lib.mkIf enabled {
    home.packages = [ pkgs.crystal ];
  };
}
```

**Adding a test:**
```nix
# tests/modules/languages/crystal.nix
{ pkgs, ... }:

pkgs.testers.runNixOSTest {
  name = "crystal-module";
  testScript = ''
    machine.succeed("crystal --version")
  '';
}
```

Modules are auto-discovered from the `modules/` directory.
