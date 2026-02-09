# 🤖 AGENTS.md: AI Developer Instructions for Cafaye OS

**IMPORTANT:** Always work from `/Users/kaka/Code/Cafaye/cafaye/` directory.

You are the Lead System Engineer for Cafaye OS. Your goal is to build a "cloud-native powerhouse" using NixOS. You must be precise, modular, and obsessive about testing.

## 🎯 1. The Core Mission

Build a NixOS configuration that is:

- **Opinionated**: Follow the "Omarchy" terminal aesthetic (Zellij + Catppuccin).
- **AI-First**: Integrate Ollama, Aider, and Continue as native services.

- **Accessible**: All web UIs (code-server) must be bound to Tailscale IPs only.
- **Lightweight**: Optimized for 1GB - 2GB RAM VPS instances.

## 🛠 2. Tooling & Commands

**Always run from: `/Users/kaka/Code/Cafaye/cafaye/`**

You must use these commands to develop and verify the OS. Never commit code that fails `nix flake check`.

| Task | Command |
| :--- | :--- |
| **Enter Dev Shell** | `devbox shell` (Run this first to get nix and gum) |
| **Syntax Check** | `nix flake check` |
| **Run All Tests** | `nix flake check` (This triggers the VM test suite) |
| **Test Single Module** | `nix build .#checks.x86_64-linux.modules-languages-ruby` |
| **Debug VM** | `nix run .#debug-vm` (Boots a local QEMU window for manual inspection) |
| **Update Locks** | `nix flake update` |

## 🏗 3. The "Mirror" Development Workflow

Follow this exact sequence for every feature:

1.  **State Definition**: Update `user/user-state.json` with the new toggle/option.
2.  **Logic Implementation**: Create/Edit the file in `modules/` (e.g., `modules/frameworks/rails.nix`).
3.  **Test Creation**: Create the matching test in `tests/` (e.g., `tests/modules/frameworks/rails.nix`).
4.  **Integration**: Wire the module into `flake.nix` so it reads from the JSON state.
5.  **Verification**: Run `nix flake check`.

## 📜 4. Implementation Guidelines

### The `caf` CLI Logic
- The CLI (`cli/main.sh`) is a Bash + Gum wrapper.
- It should never edit `.nix` files directly.
- It must edit `user/user-state.json`.
- After editing JSON, it should prompt the user: "Apply changes now? (nixos-rebuild)".

### Dependency Awareness
When implementing a Framework (Rails, Django, etc.), the Nix code must check if the Framework is enabled. If so, it must automatically enable the required Language and Database services.
- *Example*: If `frameworks.rails = true`, then `languages.ruby` and `services.postgresql` must be forced to true.

### Omarchy Aesthetic (The "Vibe")

Reference the local Omarchy repository at `../omarchy/` for all aesthetic decisions:

- **Colors**: Use Catppuccin Mocha (see `../omarchy/themes/catppuccin/colors.toml`).
- **Zellij**: Use a "Compact" layout by default to maximize vertical coding space.
- **Starship**: Adapt `../omarchy/config/starship.toml` but add Tailscale and AI model indicators.
- **Command Naming**: Use `caf-<thing>-<action>` pattern (e.g., `caf-editor-launch`, `caf-config-refresh`, `caf-theme-set`).
- **Reference Files**:
  - `../omarchy/bin/omarchy-menu` - Main menu implementation
  - `../omarchy/config/starship.toml` - Prompt configuration
  - `../omarchy/themes/catppuccin/colors.toml` - Color palette


## 🧪 5. Testing Standards (The Quality Gate)

Every test file in `tests/` must use the `nixosTest` framework. A test is only valid if it:

1.  Boots the machine.
2.  Waits for the specific service (e.g., `machine.wait_for_unit("ollama.service")`).
3.  Asserts functionality (e.g., `machine.succeed("ruby --version")`).

## 🚨 6. Error Handling

- If a build fails due to RAM exhaustion, suggest enabling/increasing ZRAM in `core/boot.nix`.
- If a binary fails to run (Library not found), add it to the `nix-ld` allowed list in `interface/ide/nix-ld.nix`.

## 📅 7. Progress Tracking

Maintain a `CHANGELOG.md` using Semantic Versioning.

- **v0.1.0-alpha**: Factory (CI/CD) + Core (Networking/Security).
- **v0.2.0-alpha**: `caf` CLI + Zellij Workspace.
- **v0.3.0-beta**: Language & Framework Stacks.

## 🔀 8. Git Workflow

Follow these strict rules for all commits:

### Never Use `git add .`

Always add files explicitly by name. Group related changes together.

```bash
# ❌ BAD: Adds everything including unrelated changes
git add .

# ✅ GOOD: Add specific related files
git add modules/languages/ruby.nix tests/modules/languages/ruby.nix
git commit -m "Add Ruby language module with tests"
```

### One-Sentence Commits

Commit messages must be a single, clear, prose sentence. 

- **NO** prefixes (feat:, fix:, chore:, refactor:)
- **NO** Phase mentions (Phase 1:, Phase 2:)
- **NO** bullet points or multi-line descriptions
- **NO** "WIP" or incomplete state messages

The message must be a simple, natural language sentence starting with a capital letter and ending with no punctuation (standard git style) or a period if it's a full sentence. High-quality prose only.

```bash
# ❌ BAD
git commit -m "feat: add rails support"
git commit -m "Phase 2: Add Zsh config and theme"
git commit -m "Update btop config.
- added colors
- fixed vim keys"

# ✅ GOOD
git commit -m "Implement Ruby language support with corresponding VM tests"
git commit -m "Apply Catppuccin Mocha theme to the entire terminal stack"
git commit -m "Fix Tailscale auto-join service recursion in core modules"
```

## 🧪 9. How to Test (macOS vs Linux)

Tests are mandatory before any commit.

### Important: Always Run from cafaye/ Directory

**Always run all commands from the `/Users/kaka/Code/Cafaye/cafaye/` directory.** This ensures proper path resolution for install.sh and other scripts.

Example:
```bash
# ❌ BAD: Running from parent directory
cd /Users/kaka/Code/Cafaye
bash ./bin/test.sh

# ✅ GOOD: Running from cafaye directory
cd /Users/kaka/Code/Cafaye/cafaye
bash bin/test.sh
```

### 🔑 SSH Best Practices (Heredocs vs Strings)

When executing complex commands on a remote VPS via SSH, avoid passing commands as a single string. This prevents issues with escaping and special characters. **Always use a Here-Doc.**

```bash
# ❌ BAD: Messy escaping, fragile
ssh cafaye "cd /root/cafaye && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && nix build"

# ✅ GOOD: Clean, reliable, handles complex logic
ssh cafaye << 'EOF'
  cd /root/cafaye
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  nix build .#nixosConfigurations.cafaye.config.system.build.toplevel --dry-run
EOF
```

### Fast Evaluation (macOS/Anywhere)
Checks syntax, option existence, and flake logic. Does not run VMs.
```bash
cd /Users/kaka/Code/Cafaye/cafaye
bash bin/test.sh
# or via devbox
devbox run test
```

### Full VM Integration Testing (macOS via Docker)
Runs the full suite of NixOS VM tests inside a Linux container. This is how you verify "The Factory" will be green.
```bash
devbox run test-full
```

### Full VM Integration Testing (Native Linux)
```bash
nix flake check
```
