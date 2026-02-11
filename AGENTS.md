# 🤖 AGENTS.md: AI Developer Instructions for Cafaye

**IMPORTANT:** Always work from `/Users/kaka/Code/Cafaye/cafaye/` directory.

You are contributing to Cafaye, a **Development Runtime** that provides reproducible, declarative development environments using Nix and Home Manager.

## 🎯 1. The Core Mission

Build a Development Runtime that is:

- **Opinionated**: Follow the "Omarchy" terminal aesthetic (Zellij + Catppuccin)
- **Reproducible**: Uses Nix and Home Manager for perfect reproducibility
- **Accessible**: Works on macOS, Ubuntu, or any VPS via SSH
- **AI-Ready**: Supports Claude Code, Aider, Ollama, and other AI tools
- **Modular**: Composable, extensible module system

## 🛠 2. Tooling & Commands

**Always run from: `/Users/kaka/Code/Cafaye/cafaye/`**

You must use these commands to develop and verify. Never commit code that fails tests.

| Task | Command |
| :--- | :--- |
| **Enter Dev Shell** | `nix develop` or `devbox shell` |
| **Syntax Check** | `nix flake check --no-build` |
| **Run Tests** | `./bin/test.sh` (fast) or `devbox run test-full` (full) |
| **Test Single Module** | `nix build .#checks.x86_64-linux.modules-languages-ruby` |
| **Update Locks** | `nix flake update` |

## 🏗 3. The Development Workflow

Follow this exact sequence for every feature:

1. **State Definition**: Update `user/user-state.json` with the new toggle/option
2. **Module Implementation**: Create/edit file in `modules/` (e.g., `modules/frameworks/rails.nix`)
3. **Test Creation**: Create matching test in `tests/` (e.g., `tests/modules/frameworks/rails.nix`)
4. **Integration**: Wire the module into `flake.nix` so it reads from the JSON state
5. **Verification**: Run `./bin/test.sh`

## 📜 4. Implementation Guidelines

### Module Structure

Every module must follow this pattern:

```nix
{ config, pkgs, lib, userState, ... }:

let
  enabled = userState.category.module or false;
in
{
  meta = {
    name = "Module Name";
    description = "What this module does";
    category = "languages"; # or services, editors, ai
  };
  
  config = lib.mkIf enabled {
    home.packages = [ pkgs.packageName ];
    # Additional configuration
  };
}
```

### The `caf` CLI Logic

- The CLI (`cli/`) is a Bash + Gum wrapper
- It should never edit `.nix` files directly
- It edits `user/user-state.json`
- After editing JSON, prompt: "Apply changes now? (caf apply)"

### Dependency Awareness

When implementing a Framework, automatically enable required dependencies:

- Example: If `frameworks.rails = true`, then enable `languages.ruby` and `services.postgresql`

### Omarchy Aesthetic (The "Vibe")

Reference the local Omarchy repository at `../omarchy/`:

- **Colors**: Use Catppuccin Mocha (`../omarchy/themes/catppuccin/colors.toml`)
- **Zellij**: Use "Compact" layout to maximize coding space
- **Starship**: Adapt `../omarchy/config/starship.toml`, add AI indicators
- **Command Naming**: Use `caf-<thing>-<action>` pattern
  - `caf-editor-launch`
  - `caf-config-refresh`
  - `caf-theme-set`

## 🧪 5. Testing Standards

Every module must have tests:

```nix
# tests/modules/languages/ruby.nix
{ pkgs, ... }:

pkgs.testers.runNixOSTest {
  name = "ruby-module";
  
  nodes.machine = { ... }: {
    imports = [ ../../modules/languages/ruby.nix ];
    _module.args.userState = { languages.ruby = true; };
  };
  
  testScript = ''
    machine.wait_for_unit("default.target")
    machine.succeed("ruby --version")
    machine.succeed("gem --version")
    print("✓ Ruby module tests passed")
  '';
}
```

Test requirements:
1. Boot the test machine
2. Wait for relevant services
3. Assert functionality with real commands

## 🚨 6. Error Handling

- Build fails due to RAM? Suggest swap/ZRAM configuration
- Binary fails (Library not found)? Add to `interface/ide/nix-ld.nix`
- Module conflicts? Use `lib.mkForce` or dependency resolution

## 📅 7. Progress Tracking

Maintain `CHANGELOG.md` using Semantic Versioning:

- **v0.1.0-alpha**: Core runtime + installer
- **v0.2.0-alpha**: CLI + basic modules
- **v0.3.0-beta**: Language & framework stacks

## 🔀 8. Git Workflow

### Never Use `git add .`

Always add files explicitly:

```bash
# ❌ BAD
# git add .

# ✅ GOOD
git add modules/languages/ruby.nix tests/modules/languages/ruby.nix
git commit -m "Add Ruby language module with tests"
```

### One-Sentence Commits

Commit messages must be a single, clear sentence:

- **NO** prefixes (feat:, fix:, chore:)
- **NO** Phase mentions (Phase 1:, Phase 2:)
- **NO** bullet points or multi-line descriptions
- **NO** "WIP" messages

```bash
# ❌ BAD
git commit -m "feat: add rails support"
git commit -m "Update btop config.
- added colors
- fixed vim keys"

# ✅ GOOD
git commit -m "Implement Ruby language support with tests"
git commit -m "Apply Catppuccin Mocha theme to terminal stack"
```

## 🧪 9. How to Test

### Important: Always Run from cafaye/ Directory

```bash
# ❌ BAD: Running from parent
cd /Users/kaka/Code/Cafaye
bash ./bin/test.sh

# ✅ GOOD: Running from project root
cd /Users/kaka/Code/Cafaye/cafaye
bash bin/test.sh
```

### 🔑 SSH Best Practices

Use Here-Docs for complex SSH commands:

```bash
# ❌ BAD: Messy escaping
ssh cafaye "cd /root/cafaye && nix build"

# ✅ GOOD: Clean Here-Doc
ssh cafaye << 'EOF'
  cd /root/cafaye
  source ~/.nix-profile/etc/profile.d/nix.sh
  nix build .#checks.x86_64-linux.core-unified
EOF
```

### Testing Commands

**Fast evaluation (macOS/Anywhere):**
```bash
cd /Users/kaka/Code/Cafaye/cafaye
bash bin/test.sh
# or via devbox
devbox run test
```

**Full integration tests (macOS via Docker):**
```bash
devbox run test-full
```

**Native Linux:**
```bash
nix flake check
```
