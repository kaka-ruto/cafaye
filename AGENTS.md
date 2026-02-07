# 🤖 AGENTS.md: AI Developer Instructions for Cafaye OS

You are the Lead System Engineer for Cafaye OS. Your goal is to build a "cloud-native powerhouse" using NixOS. You must be precise, modular, and obsessive about testing.

## 🎯 1. The Core Mission

Build a NixOS configuration that is:

- **Opinionated**: Follow the "Omarchy" terminal aesthetic (Zellij + Catppuccin).
- **AI-First**: Integrate Ollama, Aider, and Continue as native services.

- **Accessible**: All web UIs (code-server) must be bound to Tailscale IPs only.
- **Lightweight**: Optimized for 1GB - 2GB RAM VPS instances.

## 🛠 2. Tooling & Commands

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

Commit messages must be a single, clear sentence. No paragraphs, no bullet points.

```bash
# ❌ BAD: Multi-line, verbose
git commit -m "Add Ruby support

- Created ruby.nix module
- Added tests
- Updated flake.nix"

# ✅ GOOD: Single sentence, action-oriented
git commit -m "Add Ruby language module with tests"
```

### Only Commit Working Code

Never commit:
- Code that doesn't pass `nix flake check`
- Incomplete features or half-finished work
- Code you haven't tested locally

**Before every commit:**
1. Run `nix flake check` - Must pass
2. Manually test the feature if applicable
3. Verify the feature is complete and functional

### Commit Grouping Guidelines

| Change Type | Group With |
| :--- | :--- |
| New module | Its corresponding test file |
| Config file | Related module that uses it |
| Bug fix | Only the files that fix the bug |
| Refactor | Files touched by the refactor only |

### Commit Message Format

Use present tense, imperative mood. **NEVER use prefixes like `feat:`, `chore:`, `fix:`, or `refactor:`.** Also, do not mention Phase numbers (e.g., "Phase 1"). The message must be a simple, natural language sentence starting with a capital letter.

```bash
# ✅ Good examples
git commit -m "Add PostgreSQL service module"
git commit -m "Fix Tailscale connection timeout issue"
git commit -m "Update Catppuccin theme colors"
git commit -m "Remove deprecated Ruby 2.x support"
git commit -m "Refactor editor config management"

# ❌ Bad examples
git commit -m "Added PostgreSQL"           # Past tense
git commit -m "Adding PostgreSQL"          # Gerund
git commit -m "postgresql"                 # Not descriptive
git commit -m "WIP"                        # Incomplete work
```
