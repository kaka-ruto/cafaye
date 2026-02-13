# Cafaye Behavior Specification

**Cafaye is Distributed Development Infrastructure**—a fleet of synchronized development environments spanning your laptop, VPS, and desktop. This document describes the behaviors we expect from the Cafaye installer and post-setup experience.

## Philosophy

**We install the foundation for distributed development.** The installer sets up the core infrastructure (Nix, Home Manager, Ghostty terminal, tmux workspace, Zsh, Neovim, lazygit) that enables your environment to sync across machines via Git. Start with one node, grow to a fleet. Everything else—languages, frameworks, AI tools—is added later using the searchable menu or `caf install <tool>`.

**Menu-First Design:** Users should rarely need to type commands. All functionality is accessible via:

- **Keyboard shortcuts** (Super+C for menu, Super+S for search, etc.)
- **Searchable menus** (fuzzy find anything)
- **Hierarchical navigation** (arrow keys, vim bindings)
- Terminal commands are available but secondary

**Single Node or Fleet:** Cafaye works perfectly with one machine. Add more when you need them. Use `caf fleet` commands to manage multiple nodes, or ignore them if you only have one.

**Why:** This keeps installation fast (2-3 minutes), simple (minimal questions), and flexible (users add what they need, when they need it, on as many machines as they want).

---

## Table of Contents

1. [Single Directory Structure](#single-directory-structure)
2. [Testing Infrastructure](#testing-infrastructure)
3. [Installation Pattern](#installation-pattern)
4. [Pre-Installation Experience](#pre-installation-experience)
5. [Phase 1: Plan](#phase-1-plan)
6. [Phase 2: Confirm](#phase-2-confirm)
7. [Phase 3: Execute](#phase-3-execute)
8. [Post-Installation Experience](#post-installation-experience)
9. [Post-Setup Behaviors](#post-setup-behaviors)
10. [Fleet Management](#fleet-management)
11. [Testing Behaviors](#testing-behaviors)
12. [Implementation Checklist](#implementation-checklist)

---

## Single Directory Structure

**All files live in `~/.config/cafaye/`:**

```
~/.config/cafaye/
├── flake.nix              # Home Manager flake
├── flake.lock             # Locked versions
├── home.nix               # Home Manager configuration
├── environment.json       # User's environment choices
├── settings.json          # Tool settings (backup strategy, etc.)
├── modules/               # MODULE CONFIGURATIONS
│   ├── _template.nix      # Template for new modules
│   ├── languages/         # Language runtimes
│   │   ├── ruby.nix
│   │   ├── python.nix
│   │   └── ...
│   ├── frameworks/        # Web frameworks
│   │   ├── rails.nix
│   │   ├── django.nix
│   │   └── ...
│   ├── services/          # Background services
│   │   ├── postgresql.nix
│   │   ├── redis.nix
│   │   └── ...
│   ├── editors/           # Code editors
│   │   ├── neovim.nix     # Base Neovim module
│   │   └── neovim/        # Neovim distributions (subdirectory)
│   │       ├── lazyvim.nix
│   │       ├── astronvim.nix
│   │       └── nvchad.nix
│   └── ai/                # AI tools
│       ├── claude-code.nix
│       └── ...
├── dotfiles/              # Custom tool configurations
│   ├── nvim/              # Neovim config
│   ├── zsh/               # Zsh config
│   └── git/               # Git config
├── tests/                 # AUTOMATIC TEST DISCOVERY
│   ├── modules/           # Module tests (1:1 mapping with modules/)
│   ├── fixtures/          # Shared test data (ignored by discovery)
│   ├── lib/               # Test helper code (ignored by discovery)
│   ├── test-helper.nix    # Global test configuration and fixes
│   └── ...                # Any .nix file in tests/ is a test target
├── logs/                  # Installation and operation logs
├── .git/                  # Git repository for backup
└── install.sh             # Installer script (can be from Cafaye repo or user's fork)
```

**Installer Source:**
Users can install from:

1. **Official Cafaye repository** (default):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/kaka-ruto/cafaye/master/install.sh | bash
   ```
2. **User's own repository/fork** (customization):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/user/my-cafaye/main/install.sh | bash
   ```
3. **Local file** (development/testing):
   ```bash
   ./install.sh
   ```

The installer clones the repository it comes from into `~/.config/cafaye/`, so users who install from their fork get their custom modules and configurations.

**Why one directory:**

- Everything is backed up together
- Simple to clone/restore on new machines
- Clear ownership (Cafaye manages everything)
- No confusion about where settings live

**Module System:**

- Each module in `modules/` is self-contained
- Each module has a corresponding test in `tests/modules/` with identical path
- Template provided at `modules/_template.nix` for creating new modules
- Modules are conditionally imported based on `environment.json`

**Module Test Structure (1:1 Mapping):**
For every module at `modules/<category>/<name>.nix`, there MUST be a test at `tests/modules/<category>/<name>.nix`. This ensures every module has test coverage.

**Other Tests:**
Besides modules, we also test:

- Installation flow (`tests/installation/`)
- CLI commands (`tests/cli/`)
- Integration scenarios (`tests/integration/`)
- Core functionality (`tests/core/`)

**Subdirectory Support:**
Modules can have subdirectories for variants. Tests follow the same structure.

---

## Testing Infrastructure

Cafaye uses a "Rails-style" testing architecture where tests are automatically discovered and can range from simple data fixtures to complex behavioral simulations.

**Testing Strategy:**

Before any code is considered complete, it MUST pass:

1. **Automated tests** - Run via `caf test` on both:
   - [ ] Local macOS machine (development environment)
   - [ ] GCP VPS (Ubuntu, production-like environment)
2. **Manual testing** - Human verification on both:
   - [ ] Local macOS machine
   - [ ] GCP VPS via SSH

All tests must pass on BOTH environments before merging.

### The `caf test` Command

The primary interface for testing the distributed development infrastructure is the `caf test` command.

| Command              | Description                                                              |
| :------------------- | :----------------------------------------------------------------------- |
| `caf test`           | Runs the full suite (Linting + All Behavioral Tests).                    |
| `caf test --lint`    | Runs fast static analysis (Syntax checks, Shellcheck, Flake evaluation). |
| `caf test <path>`    | Runs a specific test or suite (e.g., `modules/languages/ruby`).          |
| `caf test languages` | Runs a shorthand suite (e.g., all language modules).                     |

### Hybrid Test Formats

The test discovery logic (`flake.nix`) automatically detects the format of your `.nix` test files:

1. **Pure Data (Unit Tests)**: Simply returns a `userState` attribute set. Ideal for verifying that a configuration state is valid.

   ```nix
   { languages.ruby = true; }
   ```

2. **Functional Modules (Behavioral Tests)**: A standard Nix function taking `{pkgs, ...}`. Allows for complex overrides, mock files, or custom activation logic.

3. **Direct Derivations (Integration Tests)**: Returns a full derivation (e.g., using `pkgs.testers.runNixOSTest`). Used for multi-node VM testing and installer verification.

### Test Discovery Rules

- **Automatic**: Any `.nix` file in `tests/` (recursively) is exposed as a test target.
- **Mapped Names**: Slashes are mapped to dots for Nix attributes (e.g., `tests/modules/languages/ruby.nix` becomes `modules.languages.ruby`). The CLI accepts both.
- **Exclusions**: Files in `tests/fixtures/` and `tests/lib/`, or named `test-helper.nix`, are ignored by discovery to prevent partial files from clobbering the test list.
- **Global Fixes**: `tests/test-helper.nix` is automatically injected into every discovered test, providing global fixes like disabling font-linking on Darwin sandbox environments.

---

## Installation Pattern

The installer follows a **Plan → Confirm → Execute** flow:

1. **Plan**: Collect minimum required information
2. **Confirm**: Show summary and get explicit approval
3. **Execute**: Install the foundation

---

## Pre-Installation Experience

**Purpose:** Welcome the user and validate their system.

**Visual Elements:**

- Display ASCII art logo with brand colors
- Show tagline: "The distributed development infrastructure for humans and AI"
- Show version number
- Display loading animation during system detection

**System Detection:**
The installer detects the user's system and displays findings:

- Operating system (macOS/Ubuntu/Debian)
- Architecture (x86_64/aarch64)
- Available disk space (need 2GB+)
- Internet connectivity
- Memory available

Each check shows a checkmark when passed. If any requirement is not met, the installer:

- Shows a friendly error message
- Explains what's missing in plain language
- Provides specific instructions to fix the issue
- Exits gracefully (does not crash or hang)

**Timing:** System detection completes in 2-3 seconds.

---

## Phase 1: Plan

**Purpose:** Collect only the information needed to install the foundation and set up core infrastructure.

### Section 1: Welcome

- Display welcome message explaining Cafaye
- State that installation takes 2-3 minutes
- Promise: "We'll set up the foundation with backups and secure access. You add your tools later."

### Section 2: Git Identity (Required)

**Purpose:** Required for Git commits and backup.

```
Git Configuration:

Your commits will be tagged with your identity.

Name: [Auto-detect from git config or ask] >
Email: [Auto-detect from git config or ask] >
```

- Auto-detect from existing `git config` if available
- Ask if not already configured
- Store in Git config for future commits

### Section 3: Backup Strategy (Required)

**Purpose:** Ensure user's environment is always backed up and portable.

```
Backup Configuration:

We'll automatically backup your environment changes to Git.
This keeps your setup safe and portable.

Where would you like to back up?

[✓] GitHub (recommended)
    Setup walkthrough included

[ ] GitLab
    Alternative Git hosting

[ ] Local only
    Stored on this machine only

[ ] Skip for now
    We'll still auto-commit locally

Push strategy:
( ) Push immediately (every change synced instantly)
(*) Push daily (changes batched, pushed at end of day)
( ) Push manually (you control when to sync)
```

**If GitHub selected:**

- Open browser to GitHub
- Guide user to create new repository
- Ask for repository URL
- Configure remote automatically
- Test connection

**Auto-commit behavior:**

- Every `caf apply` triggers a commit
- Use git under the hood
- Commit messages generated from state changes:
  - "Add Ruby language support"
  - "Enable PostgreSQL service"
  - "Change theme to Tokyo Night"
  - "Update Neovim configuration"
- Compare environment.json before/after to determine changes
- If multiple changes: "Add Ruby and PostgreSQL, change theme"
- Push based on selected strategy

### Section 4: Secure Access (Optional but Recommended)

**Purpose:** Enable access from any device securely.

```
Secure Access with Tailscale:

Access your distributed development infrastructure from any device securely.
No open ports, encrypted connections, works from anywhere.

Set up Tailscale?

[✓] Yes, I have an account
    Enter auth key: [tskey-auth-xxx]

[ ] Yes, help me create an account
    Opens browser to tailscale.com
    Guides you through signup

[ ] Remind me later
    Configure anytime with: caf network tailscale

[ ] No, I'll use direct SSH
    Less secure, but works
```

### Section 5: Code Editor (Optional, with defaults)

**Purpose:** Give user a working editor immediately.

```
Choose Your Editor:

📝 Neovim (Highly customizable, modal editing)
    > LazyVim (modern, recommended)
      AstroNvim (IDE-like experience)
      NvChad (fast & minimal)

🎯 Helix (Modern, batteries-included)
    Built-in LSP, tree-sitter, great defaults

🌐 VS Code Server (Browser-based)
    Access from any device via browser

⏭️ Skip (install later with: caf install <editor>)
```

- If Neovim selected, show distribution submenu
- Default: Neovim with LazyVim
- User can change later with `caf config editor`

### Section 6: Theme (Optional, with default)

**Purpose:** Set visual preference.

```
Choose Your Theme:

🎨 Catppuccin Mocha (default - dark, warm)
🌸 Catppuccin Latte (light, warm)
🗼 Tokyo Night (dark, blue-purple)
🌰 Gruvbox (dark, brown-yellow)
```

- Default: Catppuccin Mocha
- Applied to terminal, prompt, and all tools
- Change later with `caf theme set`

### Section 7: SSH Keys (VPS only, optional)

**Purpose:** Enable SSH access to VPS.

```
SSH Key Setup (optional):

🔑 Import SSH keys for server access?

[✓] From SSH agent (3 keys found)
[ ] From file: ~/.ssh/id_ed25519.pub
[ ] Paste manually
[ ] Skip (configure later with: caf config ssh)
```

- Auto-detect SSH agent keys
- Show key count and fingerprints
- Allow skip (can configure later)

### VPS Only: Auto-Shutdown

```
Auto-Shutdown (recommended for VPS):

Save costs by automatically shutting down when idle.

Enable auto-shutdown after 1 hour of inactivity?

[✓] Yes (recommended - saves money)
[ ] No (keep running 24/7)
```

- Default: Yes
- Can change later with `caf config autoshutdown`

### What We DON'T Ask

The installer does NOT ask about:

- Programming languages (install with `caf install ruby`)
- Web frameworks (install with `caf install rails`)
- Databases (install with `caf install postgresql`)
- AI tools (install with `caf install claude-code`)
- Complex configurations (use `caf setup` later)
- Auto-update (enabled by default, can disable later)
- Projects directory (user organizes their own files)

---

## Phase 2: Confirm

**Purpose:** Show what will be installed and get user approval.

**Summary Display:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 Installation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  Foundation to be installed:
    • Nix package manager
    • Home Manager
    • Ghostty terminal
    • Zsh with Starship prompt
     • tmux workspace manager
    • lazygit (for all git operations)
     • Modern CLI utilities (bat, eza, fd, ripgrep, fzf, zoxide)
     • Version manager (mise for all languages)
     • Dev tools (lazydocker, git-delta, git-standup)
     • System monitors (btop, fastfetch)
    • Your chosen editor (Neovim + LazyVim)
    • Catppuccin Mocha theme

💾 Backup:
    • GitHub repository: github.com/user/cafaye-env
    • Push strategy: Daily
    • Auto-commit: Enabled

🔐 Secure Access:
    • Tailscale: Enabled

📝 Configuration:
    • Editor: Neovim with LazyVim
    • Theme: Catppuccin Mocha
    • Git identity: John Doe <john@example.com>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💾 This will use approximately 500MB of disk space
⏱️  Installation will take 2-3 minutes
🔄 You can add languages, frameworks, and tools later via the menu or: caf install <tool>

Ready to install the foundation? [Y/n]
```

**Confirmation Requirements:**

- Show minimal, focused data
- Display disk space requirement
- Display estimated time
- Remind user they install tools later
- Require explicit [Y/n] confirmation (default to Y)
- If 'n', offer options to:
  - Go back and modify selections
  - Start over
  - Exit installer

---

## Phase 3: Execute

**Purpose:** Install the foundation with clear progress indication.

**Progress Display:**

- Overall progress bar (0-100%)
- Current step with visual indicator
- Estimated time remaining
- List of completed steps (with checkmarks)
- Current step (with spinner)
- Upcoming steps (grayed out)
- Occasional helpful tips

**Installation Steps:**

```
Installing Cafaye Foundation...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[████░░░░░░░░░░░░░░░░] 30% - About 2 minutes remaining

✅ System check complete
✅ Nix package manager installed
🔄 Installing Home Manager... (current)
⏭️  Configuring Ghostty terminal
⏭️  Setting up tmux workspace
⏭️  Initializing backup repository
⏭️  Finalizing

💡 Tip: Add tools anytime via the menu or: caf install <tool>
   Examples: caf install ruby rails postgresql
```

**Detailed Steps:**

1. **System Preparation** (10 seconds)
   - Update package lists (if needed)
   - Create `~/.config/cafaye/` directory structure
   - Check permissions

2. **Repository Setup** (30 seconds)
   - Clone the repository from where `install.sh` originated
   - If installed from `https://cafaye.sh` → clones official repo
   - If installed from user's fork → clones their fork
   - If installed locally → uses local files
   - This ensures custom modules and configs from forks are available

3. **Nix Installation** (1-2 minutes)
   - Download Nix installer
   - Run multi-user installation
   - Configure nix.conf with flakes enabled

4. **Home Manager Installation** (30 seconds)
   - Install Home Manager
   - Configure Home Manager to use `~/.config/cafaye/`
   - Set up user profile

5. **Foundation Tools Installation** (30 seconds)
   - Download base packages
   - Install Ghostty terminal (default terminal)
   - Install Zsh and Starship
   - Install tmux workspace manager with plugins
   - Install lazygit (for all git operations - no git aliases needed)
   - Install mise (universal version manager for all languages)
   - Install modern CLI utilities (bat, eza, fd, ripgrep, fzf, zoxide)
   - Install dev tools (lazydocker, git-delta, git-standup)
   - Install system monitors (btop, fastfetch)
   - Install selected editor
   - Install theme files

6. **Configuration** (30 seconds)
   - Generate `environment.json` with user choices
   - Generate `settings.json` with backup strategy
   - Generate `home.nix` from templates
   - Set up dotfiles structure
   - Configure shell

7. **Backup Initialization** (20 seconds)
   - Initialize git repository in `~/.config/cafaye/`
   - Configure Git user identity
   - If GitHub selected, add remote and test connection
   - Create initial commit: "Initial Cafaye environment setup"
   - If push strategy is immediate, push to remote

8. **Secure Access Setup** (if Tailscale selected, 20 seconds)
   - Configure Tailscale with auth key
   - Verify connection
   - Display Tailscale IP

9. **Verification** (10 seconds)
   - Verify tools installed correctly
   - Run smoke tests
   - Check for errors

**Error Handling:**
If any step fails:

- Show clear error message
- Offer options: Retry, Skip, or Abort
- Log details to `~/.config/cafaye/logs/install.log`
- Never leave system in broken state

**Timing:** Total installation takes 2-3 minutes.

---

## Post-Installation Experience

**Purpose:** Celebrate success, auto-launch the terminal workspace, and guide user to next steps.

**Auto-Launch Terminal Workspace:**

Immediately after successful installation:

- [ ] **Automatically open Ghostty terminal** (default terminal)
- [ ] **Auto-start tmux** with the Cafaye session and default layout
- [ ] **Display `caf status`** showing system info and quick tips
- [ ] **Display welcome notification** with keyboard shortcuts hint

**Visual Layout (tmux):**

```
┌─────────────────────────────────────────────────────────────────┐
│ ☕ Cafaye is Ready!                           [dashboard]       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🎉 Installation Complete!                                      │
│                                                                 │
│  Your distributed development infrastructure is ready to use.   │
│                                                                 │
│  🖥️  System Info (from caf status):                             │
│     Host: macbook-pro  |  Uptime: 2h 15m                        │
│     OS: macOS 14.5  |  Shell: zsh                              │
│                                                                 │
│  🎹 Keyboard Shortcuts (Space Leader):                          │
│     Space Space    → Open Cafaye Menu                          │
│     Space s        → Search & Install Tools                    │
│     Space h        → Show Keybindings Help                     │
│     Space g        → Fleet Status                              │
│     Space d        → Doctor (Health Check)                     │
│     Space r        → Rebuild/Apply Changes                     │
│                                                                 │
│     Power User (Alt shortcuts):                                │
│     Alt+M          → Menu    Alt+S → Search                    │
│     Alt+R          → Rebuild Alt+D → Doctor                    │
│                                                                 │
│  💡 Quick Tips:                                                 │
│     • Use lazygit for all git operations (no aliases needed)   │
│     • Press Space twice to open the menu                       │
│     • All features accessible via Space leader                 │
│                                                                 │
│  📦 Installed Tools:                                            │
│     mise, bat, eza, fd, ripgrep, fzf, zoxide, lazydocker       │
│     btop, fastfetch, git-delta, git-standup                    │
│                                                                 │
│  [Press any key to dismiss this welcome message]                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Success Display (after dismissing welcome):**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉  SUCCESS! Cafaye is installed!

    Your distributed development infrastructure is ready.

    ☕ ☕ ☕

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀  Foundation installed:
    ✅ Nix package manager
    ✅ Home Manager
    ✅ Ghostty terminal
    ✅ Zsh with Starship prompt
    ✅ tmux workspace (with resurrect & continuum)
    ✅ lazygit (use for all git ops)
    ✅ mise (version manager for all languages)
    ✅ Modern CLI utilities (bat, eza, fd, ripgrep, fzf, zoxide)
    ✅ Dev tools (lazydocker, git-delta, git-standup)
    ✅ System monitors (btop, fastfetch)
    ✅ Neovim with LazyVim
    ✅ Catppuccin Mocha theme

💾 Backup configured:
    ✅ Auto-commit enabled
    ✅ GitHub repository connected
    ✅ Daily push strategy active

🔐 Secure access:
    ✅ Tailscale configured
    ✅ Access from any device

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯  Quick Start:

    Open menu:           Space Space (or type: caf)
    Search tools:        Space s
    Show keybindings:    Space h
    Fleet status:        Space g
    Doctor:              Space d
    Rebuild:             Space r
    Start terminal:      tmux (auto-started in Ghostty)
    Open editor:         nvim
    View status:         caf status
    Manage projects:     caf project list

    Power shortcuts:     Alt+M (Menu)  Alt+S (Search)  Alt+R (Rebuild)

🛠️   Add Your Tools (via menu or commands):

    Install Ruby:        caf install ruby
    Install Rails:       caf install rails postgresql redis
    Install Node:        caf install nodejs
    Install AI tools:    caf install claude-code

    Or use the menu:     caf

⚙️   Configure Further:

    Full setup wizard:   caf setup
    Change settings:     caf config
    Backup status:       caf backup status

📦  Your configuration is at:
    ~/.config/cafaye/

📚  Documentation:  https://github.com/kaka-ruto/cafaye

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎊  Happy coding! Your environment is backed up and portable.

    "The first distributed development infrastructure built for
     collaboration between humans and AI."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Press Enter to start coding...
```

**Post-Installation Actions:**

- Auto-launch Ghostty with tmux workspace (already done)
- Show `caf doctor` command for verification
- Remind about searchable menu (`caf` or Super+C)
- Mention Super+S for quick tool search

**VPS Specific:**

- Show connection instructions clearly
- Show Tailscale IP for access
- Remind about auto-shutdown if enabled

---

## Post-Setup Behaviors

### Auto-Status on Terminal Startup

**Purpose:** Provide immediate context when opening a terminal.

**Behavior:**

Whenever a new terminal opens (Ghostty auto-launches or user opens new window):

- [x] Automatically display `caf status` before the prompt
- [x] Shows system information (hostname, OS, uptime)
- [x] Shows Cafaye environment status
- [x] Shows quick tips for common actions
- [x] Can be disabled via `caf config autostatus off`

**Display Format:**

```
┌──────────────────────────────────────────────────────────────┐
│ ☕ Cafaye Status                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  🖥️  System: macbook-pro | macOS 14.5 | Uptime: 2h 15m       │
│                                                              │
│  🌐 Fleet: 1 node (localhost)                                │
│                                                              │
│  📦 Tools: Ruby, Node.js, PostgreSQL, Redis                 │
│                                                              │
│  💡 Quick Actions:                                          │
│     Space Space → Menu    |    caf install <tool>           │
│     caf project list      |    caf status                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Menu-First Design Philosophy

**Primary Interaction Method:** Users should interact through searchable menus, not memorized commands.

**Keyboard Shortcuts (Global):**

**Primary - Space Leader:**

| Shortcut      | Action                 | When to Use                     |
| ------------- | ---------------------- | ------------------------------- |
| `Space Space` | Open Cafaye Menu       | Any terminal (double-tap Space) |
| `Space s`     | Search & Install Tools | Space, then 's'                 |
| `Space i`     | Install                | Space, then 'i'                 |
| `Space r`     | Rebuild/Apply Changes  | Space, then 'r'                 |
| `Space d`     | Doctor (Health Check)  | Space, then 'd'                 |
| `Space g`     | Fleet Status           | Space, then 'g'                 |
| `Space b`     | Backup Status          | Space, then 'b'                 |
| `Space u`     | Update System          | Space, then 'u'                 |
| `Space y`     | Sync Push/Pull         | Space, then 'y'                 |
| `Space h`     | Show Keybindings Help  | Space, then 'h'                 |
| `Space l`     | View Logs              | Space, then 'l'                 |
| `Space f`     | Find Files             | Space, then 'f'                 |
| `Space t`     | New Terminal           | Space, then 't'                 |
| `Space c`     | Edit Config            | Space, then 'c'                 |
| `Space ?`     | Show All Shortcuts     | Space, then '?'                 |
| `Space q`     | Quit/Close             | Space, then 'q'                 |

**Secondary - Alt Shortcuts (Power Users):**

| Shortcut | Action    |
| -------- | --------- |
| `Alt+M`  | Open Menu |
| `Alt+S`  | Search    |
| `Alt+I`  | Install   |
| `Alt+R`  | Rebuild   |
| `Alt+D`  | Doctor    |
| `Alt+G`  | Fleet     |
| `Alt+B`  | Backup    |
| `Alt+U`  | Update    |
| `Alt+Y`  | Sync      |

**Leader Key Behavior:**

- Double-tap `Space` within 300ms to open menu
- After single `Space`, you have 500ms to press next key
- Visual feedback: Prompt shows `[LEADER]` when active
- Customizable: Users can set leader to Space, Comma, Backslash, or Escape

**The `caf` Menu System:**

Running `caf` (or double-tapping Space) opens a hierarchical, searchable menu:

```
☕ Cafaye Menu
═══════════════════════════════════════════════════

Node: macbook-pro | Status: ✓ Synced

📦 Install        → Languages, frameworks, services
⚙️  Configure     → Settings, themes, editor
🌐 Fleet          → Multi-node management
🔄 Sync           → Backup & synchronization
🏥 Status         → Health, logs, diagnostics
🎨 Style          → Themes, fonts, appearance
🔐 Secrets        → API keys, credentials
📚 Help           → Docs, keybindings, about
👋 Exit           → Close menu

Navigation: ↑/↓ arrows, Enter to select, / to search, Q to quit
```

**Search-Driven Interface:**

Pressing `Space s` (Space then 's') opens universal search:

```
☕ Search Cafaye
═══════════════════════════════════════════════════

> ruby

Results:
  💎 Ruby (Language)
      Modern, elegant, productive

  🛤️  Ruby on Rails (Framework)
      Full-stack web framework
      Includes: Ruby, PostgreSQL, Redis

[↑/↓ to navigate, Enter to install, ESC to close]
```

**Installation via Menu:**

Path: `caf` → "📦 Install" opens categorized, searchable menu:

```
☕ Install Tools
═══════════════════════════════════════════════════

Languages:              Frameworks:
  💎 Ruby                 🛤️  Rails
  🐍 Python               🐍 Django
  🟢 Node.js              ⚛️  Next.js
  🦀 Rust                 🚀 Phoenix
  🐹 Go

Databases:              AI Tools:
  🐘 PostgreSQL            🤖 Claude Code
  🧠 Redis                 🤖 Ollama
  🐬 MySQL                 🤖 Aider
  🍃 MongoDB

Search: [/]  Back: [ESC]  Install: [Enter]
```

**Smart lazygit Integration:**

lazygit is installed by default and should be used for ALL git operations. No git aliases are provided.

- Open lazygit: `lazygit` or `lg` (if aliased)
- Or from menu: `caf` → "🏥 Status" → "lazygit"
- TUI-based, keyboard-driven interface
- Handles commits, branches, remotes, stashing, etc.

**Progress Display:**

When installing tools (via menu or command):

```
🛤️  Installing Ruby on Rails

Dependencies:
  ✓ Ruby 3.3.0
  ✓ Rails 7.1.0
  ✓ PostgreSQL 16.1
  ✓ Redis 7.2

[████████████░░░░░░░░] 60% Building Ruby 3.3.0...

✅ Rails installed!

Quick Start:
  rails new myapp
  cd myapp
  bin/rails server

📝 Auto-committed: "Add Rails framework"
```

---

## Fleet Management (Local & Remote Sync)

**Philosophy:**

- **Independent Nodes**: Each machine is an autonomous actor. It does not depend on a central server to function.
- **Git as Source of Truth**: `~/.config/cafaye` is a Git repository synced via a private remote (GitHub/GitLab).
- **Awareness via Registry**: Nodes use an encrypted "Fleet Registry" to know about each other without tight coupling.

### Terminology:

- **Local**: Your primary workstation (usually macOS or Linux Desktop).
- **Remote**: Any VPS or secondary machine (usually Linux via SSH/Tailscale).

### 1. The Fleet Registry (`secrets/fleet.yaml`)

Sensitive metadata about your nodes (IPs, provider info, roles) is stored in a SOPS-encrypted file.

- **Security**: Uses machine SSH public keys (converted to age) for encryption.
- **Privacy**: IPs, hostnames, and provider details are encrypted in the Git repo.
- **Independent Config**: The registry is used for orchestration only. nix configuration remains node-local.

### 2. Registration Flow (Local-Involved)

1. **Remote Node**: Finishes installation and provides its Public SSH Key.
2. **Local Machine**: User runs `caf fleet add <name> --key "<key>" --ip "<ip>"`.
   - Local machine adds the node to the encrypted registry.
   - Local machine adds the node's key to the SOPS recipient list (`.sops.yaml`).
   - Local machine re-encrypts the registry and pushes to Git.
3. **Remote Node**: Runs `caf sync pull`. It can now decrypt the registry because its key was authorized by Local.

### 3. Sync & Apply Behaviors

- **`caf sync push`**: Auto-commits pending state changes and pushes to the Git remote.
- **`caf sync pull`**: Pulls latest changes from Git, handles merges, and triggers `caf apply`.
- **`caf fleet status`**: Displays a dashboard of all nodes, their roles, Tailscale IPs, and sync status.
- **`caf fleet apply`**: (Orchestration) Uses SSH to trigger `caf sync pull` on all remote nodes simultaneously.

### 4. Fleet Behavioral Tests

**Test THAT:**

- **SOPS**: The registry `secrets/fleet.yaml` is unreadable/invalid if the key is not in `.sops.yaml`.
- **Encryption**: Sensitive fields (like IP) are not plain-text in the raw Git version of the file.
- **Registration**: Adding a node correctly updates the recipient list and the registry file.
- **Independent State**: Changing a setting on Node A and syncing does NOT overwrite machine-specific `local-user.nix` on Node B.
- **Sync Loop**: `caf sync pull` on a remote correctly detects new commits and triggers a Home Manager rebuild.
- **SSH Loop**: `caf fleet apply` correctly attempts to connect to remotes listed in the registry.

---

## Testing Behaviors

### Installation Tests

**Test THAT the installer:**

1. **Welcome & Detection:**
   - Shows welcome screen with logo
   - Detects system correctly
   - Validates requirements
   - Shows clear errors if requirements not met
   - User can proceed after successful detection

2. **Git Identity Collection:**
   - Detects existing Git identity if available
   - Prompts for name and email if not configured
   - Stores identity correctly
   - Uses identity for future commits

3. **Backup Setup:**
   - Shows backup options clearly
   - GitHub walkthrough works (opens browser, guides user)
   - GitLab option works
   - Local backup initializes git repo
   - Push strategy is saved correctly
   - Remote is configured and tested
   - Initial commit is created

4. **Secure Access (Tailscale):**
   - Setup option is presented
   - Auth key is accepted
   - Connection is verified
   - Skip option works
   - "Remind me later" is saved

5. **Editor Selection:**
   - User can select editor
   - If Neovim, distribution submenu appears
   - Selection is applied
   - Skip option works

6. **Theme Selection:**
   - User can select theme
   - Theme is applied to configuration

7. **SSH Keys (VPS):**
   - Auto-detects SSH agent keys
   - Allows selection of keys
   - Allows manual entry
   - Skip option works

8. **Confirmation:**
   - Summary shows all collected data
   - Disk space and time are displayed
   - User can confirm with Y/n
   - User can go back and modify
   - User can cancel

9. **Execution:**
   - Installation progresses through steps
   - Progress bar updates
   - Each step completes successfully
   - Errors are handled gracefully
   - System is not left broken

10. **Backup Initialization:**
    - Git repo initialized in `~/.config/cafaye/`
    - Git identity configured
    - Remote added (if GitHub selected)
    - Initial commit created
    - Auto-commit system is working

11. **Success:**
    - Success screen displays
    - All installed components listed
    - Quick start commands shown
    - Tool addition examples shown
    - User can start using immediately

12. **Idempotency:**
    - Running installer again detects existing installation
    - Offers: reconfigure, update, reinstall, exit
    - Does not break existing installation

### Post-Setup Tests

**Menu System:**

- [ ] User can open main menu with double-tap Space (Space Space)
- [ ] User can open main menu with Alt+M
- [ ] User can trigger commands with Space leader (Space s for search, Space r for rebuild, etc.)
- [ ] User can trigger commands with Alt shortcuts (Alt+S, Alt+R, Alt+D, etc.)
- [ ] User sees [LEADER] in prompt when Space leader is active
- [ ] User can navigate menus with arrow keys or vim keys (j/k)
- [ ] User can search within menus using / key
- [ ] User can access submenus and go back with arrow keys or h/l
- [ ] Leader timeout works correctly (500ms default)
- [ ] Double-tap detection prevents accidental menu opening
- [ ] Leader key is customizable via config
- [ ] Keyboard shortcuts work from any terminal
- [ ] Keyboard shortcuts work over SSH
- [ ] Visual feedback shows active leader state

**Terminal Workspace (Ghostty + tmux):**

- [ ] Ghostty opens automatically after installation
- [ ] tmux session "cafaye" auto-starts with Ghostty
- [ ] Default layout loads: dashboard | terminal | git
- [ ] Window 1 (dashboard) shows node info and shortcuts
- [ ] Window 2 (terminal) provides full terminal access
- [ ] Window 3 (git) auto-starts lazygit
- [ ] User can switch windows with Alt+1/2/3
- [ ] User can create custom tmux layouts
- [ ] Fleet window appears when 2+ nodes configured
- [ ] Fleet window shows live view of multiple nodes
- [ ] tmux sessions persist across disconnects
- [ ] User can switch between tmux sessions (nodes)

**Configuration Management:**

- [ ] User edits configs only in ~/.config/cafaye/config/user/
- [ ] User never needs to edit ~/.config/cafaye/config/cafaye/
- [ ] Changes to user configs are tracked in git
- [ ] Symlinks created from ~/.config/ to cafaye/config/user/
- [ ] Custom tmux layouts work and are loadable
- [ ] Custom ghostty settings apply correctly
- [ ] Custom lazygit commands appear in UI
- [ ] Custom zsh aliases work after reload

**Neovim Customization (All Distros):**

- [ ] AstroNvim: user plugins load from config/user/nvim/astronvim/
- [ ] AstroNvim: user mappings override defaults
- [ ] AstroNvim: polish.lua runs last
- [ ] LazyVim: user options in config/user/nvim/lazyvim/options.lua
- [ ] LazyVim: user plugins in config/user/nvim/lazyvim/plugins/
- [ ] LazyVim: user keymaps override defaults
- [ ] NvChad: chadrc.lua customizes UI
- [ ] NvChad: mappings.lua adds keybindings
- [ ] NvChad: plugins.lua adds plugins
- [ ] Can switch between nvim distros with caf config
- [ ] Previous distro config backed up before switch
- [ ] User configs persist when switching distros

**Installation:**

- User can install tool via menu
- User can install tool via command
- Progress shows during installation
- Success message appears with next steps
- Changes auto-commit to git

**Fleet:**

- User can view fleet status
- User can add node to fleet
- Sync generates descriptive commit message
- Fleet apply works across nodes

## Configuration System Behaviors

### Directory Structure Behavior

**Structure:**

```
~/.config/cafaye/
├── config/
│   ├── cafaye/          # Managed by Cafaye (DO NOT EDIT)
│   │   ├── tmux/
│   │   ├── ghostty/
│   │   ├── lazygit/
│   │   ├── nvim/
│   │   │   ├── astronvim/
│   │   │   ├── lazyvim/
│   │   │   └── nvchad/
│   │   └── zsh/
│   │
│   └── user/            # User customizations (EDIT HERE)
│       ├── tmux/
│       ├── ghostty/
│       ├── lazygit/
│       ├── nvim/
│       │   ├── astronvim/
│       │   ├── lazyvim/
│       │   └── nvchad/
│       └── zsh/
```

**Behavior:**

- [x] cafaye/ directory contains defaults installed by Cafaye
- [x] user/ directory contains user customizations
- [x] User customizations **append** to or **overlay** Cafaye defaults using Nix's merge system (lists like aliases and packages are combined).
- [x] Files in cafaye/ can be updated by Cafaye without affecting user/
- [x] Both directories are in the same git repository
- [x] Changes to user/ are tracked in git
- [x] Changes to cafaye/ are tracked in git separately

### Symlink Behavior

**Standard locations symlinked:**

- [ ] ~/.config/tmux/ → ~/.config/cafaye/config/cafaye/tmux/
- [ ] ~/.config/ghostty/ → ~/.config/cafaye/config/cafaye/ghostty/
- [ ] ~/.config/lazygit/ → ~/.config/cafaye/config/cafaye/lazygit/
- [ ] ~/.config/nvim/lua/user/ → ~/.config/cafaye/config/user/nvim/{distro}/
- [ ] ~/.zshrc → ~/.config/cafaye/config/cafaye/zsh/.zshrc

**Behavior:**

- [ ] Symlinks created during installation
- [ ] Tools read configs from standard locations
- [ ] User edits appear in ~/.config/cafaye/config/user/
- [ ] Changes apply immediately (for most tools)

### Neovim Distribution Management

**Installation:**

```bash
caf install neovim --distro astronvim
# OR
caf install neovim --distro lazyvim
# OR
caf install neovim --distro nvchad
```

**Behavior:**

- [x] Copies distro template to ~/.config/nvim/ (Via setup script)
- [x] Creates ~/.config/nvim/.cafaye-distro marker file (Via setup script)
- [x] Creates user/ customization directory for that distro
- [x] Creates symlinks from ~/.config/nvim/ to user/ files (Via Nix module)
- [x] Leaves other distro directories untouched in user/

**Switching Distros:**

```bash
caf config neovim distro lazyvim
```

**Behavior:**

- [ ] Backs up current ~/.config/nvim/ to nvim-backup-{timestamp}/
- [ ] Copies new distro template to ~/.config/nvim/
- [ ] Updates .cafaye-distro marker
- [ ] Creates/updates symlinks to user/{new-distro}/
- [ ] Preserves previous distro's user/ configs
- [ ] User can restore backup if needed

**Customization Pattern (AstroNvim Example):**

```
~/.config/nvim/                           ~/.config/cafaye/config/user/nvim/astronvim/
├── init.lua (base)                       ├── plugins.lua ────────┐
├── lua/                                  ├── mappings.lua ───────┤
│   ├── plugins/                          ├── highlights.lua ─────┤
│   │   ├── astronvim plugins...          └── polish.lua ─────────┤
│   │   └── user.lua ─────────────────────────────────────────────┘
│   ├── polish.lua ───────────────────────────────────────────────┘
│   ├── mappings.lua ─────────────────────────────────────────────┘
│   └── highlights.lua ───────────────────────────────────────────┘
└── .cafaye-distro ("astronvim")
```

### User Customization Files

**Each file created with:**

- [ ] Header comment explaining the file's purpose
- [ ] Instructions on how to customize
- [ ] Links to official documentation
- [ ] Multiple commented examples
- [ ] Placeholder for user's customizations

**Example Structure:**

```bash
# Header with file purpose
# Link to documentation
# Instructions

# ═══════════════════════════════════════════════════════════════════
# EXAMPLE SECTION
# ═══════════════════════════════════════════════════════════════════
# Example 1: Basic setting
# set -g option value

# Example 2: With explanation
# bind key command  # What this does

# ═══════════════════════════════════════════════════════════════════
# YOUR CUSTOMIZATIONS BELOW
# ═══════════════════════════════════════════════════════════════════
# (User adds their own here)
```

### Multi-Environment Testing Requirements

**All features MUST be tested on:**

1. **Automated Tests:**
   - [ ] Local macOS machine
   - [x] GCP VPS (Ubuntu)

2. **Manual Testing:**
   - [ ] Local macOS machine
   - [x] GCP VPS via SSH

**Testing Checklist for Each Feature:**

- [ ] Automated tests pass on macOS
- [x] Automated tests pass on GCP VPS
- [ ] Manual testing completed on macOS
- [x] Manual testing completed on GCP VPS
- [ ] No regressions in existing functionality

### Test Writing Principles

**Describe behaviors, not implementations:**

Good: "User can configure GitHub backup and remote is set up correctly"
Bad: "git remote add origin command runs"

Good: "Installer detects existing Git identity"
Bad: "Function read_git_config returns name and email"

Good: "User sees progress as installation completes"
Bad: "Progress bar renders at 25%"

**Test the installation journey:**

- Given a fresh system
- When the user runs the installer
- Then they see welcome and system detection
- And they can enter Git identity
- And they can configure backup
- And they can configure secure access
- And they can select editor and theme
- And they see confirmation summary
- And installation progresses
- And Ghostty terminal auto-launches with tmux
- And tmux session "cafaye" is created
- And default layout loads (dashboard | terminal | git)
- And backup repo is initialized
- And they see success message
- And they can start using Cafaye via Space leader (Space Space) or Alt+M
- And they can search with Space s or Alt+S
- And they can rebuild with Space r or Alt+R
- And user customization files exist with examples
- And symlinks point to correct locations
- And they can customize tmux, ghostty, lazygit, nvim, zsh
- And their customizations are tracked in git

---

## Technical Requirements

### Visual Requirements

- Support both light and dark terminal themes
- Handle terminal resize gracefully
- Support keyboard navigation (arrow keys, Tab, Enter, Space)
- Support Ctrl+C to cancel with confirmation
- Use consistent colors:
  - Green: Success, completion
  - Yellow: Warnings, tips
  - Red: Errors (only when blocking)
  - Blue: Information, progress
  - Purple/Magenta: Brand accent

### Data Collection

**Required:**

- Git identity (name, email)
- Backup strategy and remote (or local)
- Confirmation to proceed

**Optional:**

- Secure access (Tailscale)
- Editor selection (with default)
- Theme (with default)
- SSH keys (VPS only)
- Auto-shutdown (VPS only, with default)

**Not asked:**

- Languages, frameworks, databases, AI tools
- Auto-update (enabled by default)
- Projects directory

### File Locations

All in `~/.config/cafaye/`:

- `environment.json` - User's environment choices
- `settings.json` - Tool settings (backup strategy, update prefs)
- `flake.nix` - Home Manager flake
- `home.nix` - Home Manager configuration
- `dotfiles/` - Custom tool configs
- `logs/` - Installation and operation logs
- `.git/` - Git repository

### Backup Behavior

**Auto-commit triggers:**

- Every `caf apply` command
- Every `caf install` command
- Every `caf config` change

**Commit message generation:**

- Compare `environment.json` before/after
- Detect additions: "Add {tool} {category}"
- Detect removals: "Remove {tool} {category}"
- Detect changes: "Change {setting} to {value}"
- Multiple changes: "Add Ruby and PostgreSQL, change theme"

**Push behavior:**

- Immediate: Push after every commit
- Daily: Queue commits, push at end of day
- Manual: Notify user commits are ready to push

### Logging

- Log to `~/.config/cafaye/logs/install.log`
- Include timestamps
- Include commands and errors
- Rotate logs (keep last 5)

### Idempotency

- Detect existing installation
- Offer: reconfigure, update, reinstall, exit
- Never break existing installation

### Exit Codes

- 0: Success
- 1: General error
- 2: Requirements not met
- 3: User cancelled
- 4: Network error
- 5: Disk space error

---

## Implementation Checklist

### Pre-Install

- [x] Logo display
- [x] System detection
- [x] Requirements validation
- [x] Error messages

### Plan Phase

- [x] Welcome message
- [x] Git identity detection/collection
- [x] Backup strategy (GitHub walkthrough - manual URL)
- [x] Secure access (Tailscale setup)
- [x] Editor selection (with distribution submenu)
- [x] Theme selection
- [x] SSH keys (VPS only)
- [x] Auto-shutdown (VPS only)

### Confirm Phase

- [x] Summary generation
- [x] Summary display
- [x] Confirmation prompt
- [x] Modify/restart/exit options

### Execute Phase

- [x] Progress tracking
- [x] Step-by-step execution
- [x] Error handling
- [x] Warning display
- [x] Time estimation
- [ ] Ghostty terminal installation
- [ ] tmux workspace setup
- [ ] lazygit installation

### Backup Initialization

- [x] Git repo initialization
- [x] Git identity configuration
- [x] Remote configuration
- [x] Initial commit
- [x] Push (if strategy is immediate)

### Post-Install

- [x] Success screen
- [x] Tool addition examples
- [x] Quick start commands
- [x] Documentation links
- [ ] Auto-launch Ghostty with tmux
- [ ] Welcome message in tmux
- [ ] Keyboard shortcuts hint

### Terminal Workspace

- [ ] Ghostty as default terminal
- [ ] tmux auto-start on terminal open
- [ ] Cafaye layout for tmux
- [ ] lazygit for all git operations

### Menu System (Menu-First Design)

- [ ] Main menu (`caf` or Space Space)
- [ ] Hierarchical submenus with keyboard navigation
- [ ] Search interface (Space s)
- [ ] Space leader key system (double-tap Space)
- [ ] Alt shortcuts for power users (Alt+M, Alt+S, Alt+R, etc.)
- [ ] Visual prompt feedback showing [LEADER] when active
- [ ] 500ms leader timeout (configurable)
- [ ] 300ms double-tap detection window
- [ ] Customizable leader key (Space, Comma, Backslash, Escape)
- [ ] Progress display during installs
- [ ] Quick install from search

### Terminal Workspace (Ghostty + tmux)

- [x] Ghostty installed and configured as default terminal
- [ ] Ghostty auto-launches after Cafaye installation
- [x] Ghostty config in ~/.config/cafaye/config/user/ghostty/
- [x] tmux installed and auto-starts with Ghostty
- [x] tmux session "cafaye" created automatically
- [x] Default tmux layout: dashboard | terminal | git
- [x] Window 1: dashboard with node info and shortcuts
- [x] Window 2: terminal for general work
- [ ] Window 3: git with lazygit auto-started
- [ ] Window switching with Alt+1/2/3/4/5
- [x] Custom tmux layouts in ~/.config/cafaye/config/user/tmux/layouts/
- [ ] Fleet window for multi-node monitoring
- [ ] tmux-resurrect for session persistence
- [ ] tmux-continuum for auto-save
- [x] User tmux config in ~/.config/cafaye/config/user/tmux/tmux.conf
- [x] Symlink: ~/.config/tmux/ -> ~/.config/cafaye/config/cafaye/tmux/

### Utility Scripts (~/.config/cafaye/bin/)

Cafaye provides a `bin/` directory with utility scripts that are automatically added to PATH.

**Core Scripts:**

- [x] `tat` - tmux attach/create helper (attach to existing or create new session)
- [x] `tm` - tmux session manager (fzf-based session switching)
- [x] `extract` - Universal archive extractor (handles .tar, .zip, .rar, etc.)
- [ ] `c` - Quick cd with fzf (fuzzy find directories)
- [x] `killport` - Kill process using a specific port
- [x] `serve` - Simple HTTP server in current directory
- [x] `weather` - Quick weather display
- [x] `ipinfo` - Display public and local IP addresses

**Project Management:**

- [x] `caf-project-create` - Create new project with tmux session
- [x] `caf-project-switch` - Switch between project sessions
- [x] `caf-project-list` - List all projects with status

**Git Helpers:**

- [x] `git-clone-cd` - Clone and cd into repository
- [x] `git-sync` - Pull, commit, push in one command
- [x] `git-clean-branches` - Remove merged branches

**PATH Integration:**

- [x] `~/.config/cafaye/bin/` added to PATH in zsh
- [x] Scripts use fzf for interactive selection
- [x] Scripts handle errors gracefully

### caf project Command

**Purpose:** Manage multiple development projects with isolated tmux sessions.

**Commands:**

```bash
caf project                    # List all projects
caf project create <name>      # Create new project session
caf project switch <name>      # Switch to project session
caf project delete <name>      # Delete project session
caf project rename <old> <new> # Rename project
caf project backup <name>      # Backup project state
caf project restore <name>     # Restore from backup
```

**Behavior:**

- [x] Each project gets its own tmux session
- [x] Projects stored in `~/.config/cafaye/projects.json`
- [x] Project directory can be anywhere (not just ~/projects/)
- [x] `caf project create myapp --path ~/work/myapp` creates session linked to directory
- [ ] Switching projects preserves tmux session state
- [ ] Projects can have custom tmux layouts
- [x] `caf project list` shows all projects with:
  - Project name
  - Directory path
  - Active/Inactive status
  - Last accessed time
  - Associated tools/languages

**Session Management:**

- [x] `caf project switch` uses fzf if no name provided
- [ ] Sessions persist across reboots (tmux-resurrect)
- [ ] Auto-save session every 15 minutes (tmux-continuum)
- [ ] Projects can be organized with tags/categories

**Integration:**

- [x] `caf status` shows current project
- [ ] Fleet view shows projects across nodes
- [ ] Projects can be synced between nodes via git

### Configuration Architecture

- [ ] Single directory: ~/.config/cafaye/config/
- [ ] cafaye/ subdirectory for defaults (auto-updated)
- [ ] user/ subdirectory for customizations (user-edited)
- [ ] Symlinks from ~/.config/ to cafaye/config/cafaye/
- [ ] All user configs tracked in git
- [ ] Defaults never overwritten by user edits
- [ ] User configs survive Cafaye updates
- [ ] README.md in config/user/ explaining structure

### Git UI (lazygit)

- [ ] lazygit installed and auto-starts in tmux window 3
- [ ] lazygit config in ~/.config/cafaye/config/user/lazygit/
- [ ] Catppuccin theme applied
- [ ] Custom commands can be added
- [ ] Symlink: ~/.config/lazygit/ -> ~/.config/cafaye/config/cafaye/lazygit/

### Neovim (All Distributions)

**AstroNvim:**

- [ ] Complete AstroNvim template in config/cafaye/nvim/astronvim/
- [ ] User plugins: config/user/nvim/astronvim/plugins.lua
- [ ] User mappings: config/user/nvim/astronvim/mappings.lua
- [ ] User highlights: config/user/nvim/astronvim/highlights.lua
- [ ] User polish: config/user/nvim/astronvim/polish.lua
- [ ] Symlinks to ~/.config/nvim/lua/

**LazyVim:**

- [ ] Complete LazyVim template in config/cafaye/nvim/lazyvim/
- [ ] User options: config/user/nvim/lazyvim/options.lua
- [ ] User keymaps: config/user/nvim/lazyvim/keymaps.lua
- [ ] User autocmds: config/user/nvim/lazyvim/autocmds.lua
- [ ] User plugins: config/user/nvim/lazyvim/plugins/
- [ ] Symlinks to ~/.config/nvim/lua/config/ and lua/plugins/

**NvChad:**

- [ ] Complete NvChad template in config/cafaye/nvim/nvchad/
- [ ] User chadrc: config/user/nvim/nvchad/chadrc.lua
- [ ] User mappings: config/user/nvim/nvchad/mappings.lua
- [ ] User options: config/user/nvim/nvchad/options.lua
- [ ] User plugins: config/user/nvim/nvchad/plugins.lua
- [ ] User configs: config/user/nvim/nvchad/configs/
- [ ] Symlinks to ~/.config/nvim/lua/

**General:**

- [ ] caf install neovim --distro <astronvim|lazyvim|nvchad>
- [ ] caf config neovim distro <distro> to switch
- [ ] Backup created before switching distros
- [ ] .cafaye-distro marker file

### Shell (Zsh)

- [ ] Zsh configured with Starship prompt
- [ ] User aliases/functions: config/user/zsh/custom.zsh
- [ ] Cafaye integration in prompt
- [ ] Space leader detection in Zsh
- [ ] Symlink: ~/.zshrc -> ~/.config/cafaye/config/cafaye/zsh/.zshrc
- [ ] fzf integration (Ctrl+R history, Ctrl+T files)
- [ ] zoxide integration (auto-cd to frequent directories)
- [ ] Better history search (fzf-based)
- [ ] Custom completion for caf commands

### Fonts

- [ ] Nerd Fonts auto-installed via Nix
- [ ] JetBrains Mono default
- [ ] Fira Code alternative
- [ ] Font config in ghostty config

### Multi-Node (Fleet)

- [ ] Fleet window in tmux for node overview
- [ ] SSH attach to each node in separate panes
- [ ] Session per node (tmux sessions)
- [ ] Switch sessions with caf or Space .
- [ ] Visual indicator of current node
- [ ] Sync status shown for each node

### Testing Requirements

**Automated Tests (macOS + GCP VPS):**

- [ ] Installation creates correct directory structure
- [ ] Symlinks created correctly
- [ ] Ghostty auto-launches
- [ ] tmux auto-starts
- [ ] Default layout loads
- [ ] Space leader works
- [ ] User configs override defaults
- [ ] Configs tracked in git

**Manual Tests (macOS + GCP VPS):**

- [ ] User can customize tmux prefix
- [ ] User can create custom tmux layout
- [ ] User can add lazygit custom command
- [ ] User can customize ghostty theme
- [ ] User can add nvim plugin (each distro)
- [ ] User can switch nvim distro
- [ ] User configs persist across sync
- [ ] Fleet window shows multiple nodes

### Technical

- [x] TUI elements
- [x] Single directory structure
- [x] State persistence
- [x] Logging
- [x] Signal handling
- [x] Idempotency
- [x] Exit codes

### Module System

- [x] Module template at `modules/_template.nix`
- [x] Module auto-discovery from `modules/` directory
- [x] Each module self-contained with meta information
- [x] Dependency resolution between modules (handled by Nix)

### Test Structure (1:1 Mapping)

- [x] Tests directory mirrors modules directory exactly
- [x] Every module has corresponding test file
- [x] Test path: `tests/modules/<category>/<name>.nix` for `modules/<category>/<name>.nix`
- [x] Module creation template includes test file template (commented)
- [x] CI enforces 1:1 mapping (verified via nix flake check)

### Testing (Installation Only)

- [x] Installation flow tests
- [x] Git identity collection tests
- [x] Backup setup tests
- [x] Secure access tests
- [x] Editor selection tests
- [x] Confirmation tests
- [x] Execution tests
- [x] Backup initialization tests
- [x] Error handling tests
- [x] Idempotency tests
- [x] Detects OS & Arch
- [x] Prompts for Git Identity (only if missing)
- [x] Prompts for Backup Strategy
- [x] Prompts for Editor
- [x] Prompts for Theme
- [x] Supports `--yes` flag for non-interactive installs (used in testing)
- [x] Idempotency: Detects existing installation and offers Update/Reconfigure/Clean options

### Multi-Environment Testing

- [ ] Automated tests pass on local macOS
- [x] Automated tests pass on GCP VPS
- [ ] Manual testing completed on local macOS
- [x] Manual testing completed on GCP VPS

### Phase 1: Core UX (High Priority)

- [ ] Auto-launch Ghostty with tmux after install
- [x] Welcome screen in tmux with shortcuts
- [ ] Main menu system (`caf` with hierarchical menus)
- [ ] Global keyboard shortcuts (Super+C, Super+S, etc.)
- [ ] Search interface (Super+S)
- [ ] Installation progress display
- [x] lazygit installed and configured
- [x] Auto-status on terminal startup

### Version Manager & CLI Tools

**mise (Version Manager):**

- [ ] mise installed as universal version manager
- [ ] mise auto-installs language runtimes on first use
- [ ] mise config in ~/.config/cafaye/config/user/mise/
- [ ] User can override versions per project with .tool-versions
- [ ] mise plugins for: ruby, nodejs, python, rust, go, java, etc.

**CLI Utilities:**

- [ ] bat - cat alternative with syntax highlighting
- [ ] eza - modern ls alternative with icons
- [ ] fd - fast find alternative
- [ ] ripgrep - fast grep alternative
- [ ] fzf - fuzzy finder (used throughout)
- [ ] zoxide - smart cd with history

**Dev Tools:**

- [ ] lazydocker - terminal Docker UI
- [ ] git-delta - modern git diff viewer
- [ ] git-standup - show yesterday's commits

**System Tools:**

- [ ] btop - modern htop alternative
- [ ] fastfetch - neofetch alternative

### Utility Scripts (~/.config/cafaye/bin/)

- [ ] bin/ directory created during installation
- [x] Scripts added to PATH via zsh config
- [x] tat - tmux attach helper
- [x] tm - tmux session manager with fzf
- [x] extract - universal archive extractor
- [ ] c - quick cd with fzf
- [x] killport - kill process on port
- [x] serve - simple HTTP server
- [x] weather - weather display
- [x] ipinfo - IP address display
- [x] git-clone-cd - clone and cd
- [x] git-sync - pull, commit, push
- [x] git-clean-branches - remove merged branches

### caf project Command

- [x] caf project list - show all projects
- [x] caf project create <name> - create project session
- [x] caf project switch <name> - switch to project
- [x] caf project delete <name> - delete project
- [x] Project directory can be anywhere
- [x] Projects stored in projects.json
- [x] fzf-based selection if no name provided
- [ ] tmux-resurrect persistence
- [ ] Auto-save with tmux-continuum

### Phase 2: Fleet & Sync (High Priority)

- [ ] Fleet status dashboard
- [ ] Fleet add workflow
- [ ] Sync push/pull with auto-commit
- [ ] Conflict resolution UI
- [ ] Fleet apply orchestration

### Phase 3: Polish (Medium Priority)

- [ ] Theme switching with live preview
- [ ] Configuration editor (`caf config`)
- [ ] Backup status detailed view
- [ ] Error recovery (rollback, retry)
- [ ] Inline hints system

---

## Example Session

```
$ curl -fsSL https://cafaye.com/install.sh | bash

[Logo appears with system detection]

✓ macOS 14.2 (Apple Silicon)
✓ 245GB disk space available
✓ 16GB memory
✓ Internet connected

Press Enter to continue...

[Welcome message]

Git Configuration:
Name: [John Doe] >
Email: [john@example.com] >

Backup Configuration:
Where would you like to back up?
> [✓] GitHub (recommended)
  [ ] GitLab
  [ ] Local only
  [ ] Skip for now

Push strategy:
( ) Push immediately
(*) Push daily
( ) Push manually

[GitHub walkthrough opens browser...]
Repository URL: [github.com/johndoe/cafaye-env] >

Secure Access with Tailscale:
Set up Tailscale?
> [✓] Yes, I have an account
[Auth key: tskey-auth-xxx]

Choose Your Editor:
> 📝 Neovim
  > LazyVim

Choose Your Theme:
> 🎨 Catppuccin Mocha

[VPS only: Auto-shutdown? Yes]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 Installation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready? [Y/n] >

[Installation progress...]

[████████████████████] 100%

🎉 SUCCESS! Cafaye is installed!

Foundation installed:
✅ Nix + Home Manager
✅ Ghostty terminal
✅ Zsh + Starship
✅ tmux workspace
✅ lazygit
✅ Neovim + LazyVim
✅ Backup configured
✅ Tailscale connected

[Auto-launches Ghostty with tmux welcome screen]

Add your tools:
  Press Super+S to search and install
  Or: caf install ruby rails
  Or: caf install nodejs
  Or: caf install claude-code

☕ ~
```

**Total time:** 2-3 minutes  
**Total questions:** 6 (all with sensible defaults)  
**User actions:** Mostly pressing Enter to accept defaults, then using menus
