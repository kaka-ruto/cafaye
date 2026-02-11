# Cafaye Installation Behavior Specification

This document describes the behaviors we expect from the Cafaye installer. We describe WHAT should happen, not HOW it's implemented.

## Philosophy

**We install the foundation only.** The installer sets up the core runtime (Nix, Home Manager, shell, basic tools). Everything else—languages, frameworks, AI tools—is added later by the user using `caf install <tool>`.

**Why:** This keeps installation fast (2-3 minutes), simple (minimal questions), and flexible (users add what they need, when they need it).

## Single Directory Structure

**All files live in `~/.config/cafaye/`:**

```
~/.config/cafaye/
├── flake.nix              # Home Manager flake
├── flake.lock             # Locked versions
├── home.nix               # Home Manager configuration
├── environment.json       # User's environment choices
├── settings.json          # Tool settings (backup strategy, etc.)
├── modules/               # MODULE CONFIGURATIONS (1:1 test mapping)
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
├── tests/                 # ALL TESTS
│   ├── modules/           # Module tests (1:1 mapping with modules/)
│   │   ├── languages/
│   │   │   └── ruby.nix   # Tests modules/languages/ruby.nix
│   │   ├── frameworks/
│   │   │   └── rails.nix  # Tests modules/frameworks/rails.nix
│   │   ├── editors/
│   │   │   ├── neovim.nix              # Tests modules/editors/neovim.nix
│   │   │   └── neovim/                 # Tests subdirectory modules
│   │   │       ├── lazyvim.nix         # Tests modules/editors/neovim/lazyvim.nix
│   │   │       └── astronvim.nix       # Tests modules/editors/neovim/astronvim.nix
│   │   └── ...            # Mirrors modules/ structure exactly
│   ├── installation/      # Installer behavior tests
│   ├── cli/               # CLI command tests
│   ├── integration/       # Integration scenario tests
│   └── core/              # Core functionality tests
├── logs/                  # Installation and operation logs
└── .git/                  # Git repository for backup
```

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
- Show tagline: "The first Development Runtime built for collaboration between humans and AI"
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

Access your Development Runtime from any device securely.
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
    • Zsh with Starship prompt
    • Terminal tools (zellij, fzf, etc.)
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
🔄 You can add languages, frameworks, and tools later with: caf install <tool>

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
⏭️  Configuring shell and editor
⏭️  Setting up themes
⏭️  Initializing backup repository
⏭️  Finalizing

💡 Tip: Add tools anytime with: caf install <tool>
   Examples: caf install ruby rails postgresql
```

**Detailed Steps:**

1. **System Preparation** (10 seconds)
   - Update package lists (if needed)
   - Create `~/.config/cafaye/` directory structure
   - Check permissions

2. **Nix Installation** (1-2 minutes)
   - Download Nix installer
   - Run multi-user installation
   - Configure nix.conf with flakes enabled

3. **Home Manager Installation** (30 seconds)
   - Install Home Manager
   - Configure Home Manager to use `~/.config/cafaye/`
   - Set up user profile

4. **Foundation Tools Installation** (30 seconds)
   - Download base packages
   - Install Zsh and Starship
   - Install terminal tools (zellij, fzf, zoxide, etc.)
   - Install selected editor
   - Install theme files

5. **Configuration** (30 seconds)
   - Generate `environment.json` with user choices
   - Generate `settings.json` with backup strategy
   - Generate `home.nix` from templates
   - Set up dotfiles structure
   - Configure shell

6. **Backup Initialization** (20 seconds)
   - Initialize git repository in `~/.config/cafaye/`
   - Configure Git user identity
   - If GitHub selected, add remote and test connection
   - Create initial commit: "Initial Cafaye environment setup"
   - If push strategy is immediate, push to remote

7. **Secure Access Setup** (if Tailscale selected, 20 seconds)
   - Configure Tailscale with auth key
   - Verify connection
   - Display Tailscale IP

8. **Verification** (10 seconds)
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

**Purpose:** Celebrate success and guide user to next steps.

**Success Display:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉  SUCCESS! Cafaye is installed!

    Your Development Runtime is ready.

    ☕ ☕ ☕

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀  Foundation installed:
    ✅ Nix package manager
    ✅ Home Manager
    ✅ Zsh with Starship prompt
    ✅ Terminal tools (zellij, fzf, etc.)
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

    Start terminal:      zellij
    Open editor:         nvim
    Main menu:           caf

🛠️   Add Your Tools:

    Install Ruby:        caf install ruby
    Install Rails:       caf install rails postgresql redis
    Install Node:        caf install nodejs
    Install AI tools:    caf install claude-code

    See all available:   caf search

⚙️   Configure Further:

    Full setup wizard:   caf setup
    Change settings:     caf config
    Backup status:       caf backup status

📦  Your configuration is at:
    ~/.config/cafaye/

📚  Documentation:  https://github.com/kaka-ruto/cafaye

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎊  Happy coding! Your environment is backed up and portable.

    "The first Development Runtime built for
     collaboration between humans and AI."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Press Enter to start coding...
```

**Post-Installation Actions:**

- Offer to start a new shell immediately
- Show `caf doctor` command for verification
- Remind about `caf install` for adding tools
- Mention `caf setup` for full configuration wizard

**VPS Specific:**

- Show connection instructions clearly
- Show Tailscale IP for access
- Remind about auto-shutdown if enabled

---

## Testing Behaviors (Installation Phase Only)

We test **what happens during installation**, not tool additions later.
Test directories must map 1:1 to code directories.

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

### What We Test

**User experiences during installation:**

- User can install Cafaye foundation
- User can configure backup during installation
- User can configure secure access during installation
- User can select editor and theme
- Installation completes successfully
- Backup repository is initialized
- User can start using Cafaye immediately

### What We DON'T Test (Installation Phase)

**Not tested during installation:**

- Tool installation (that's `caf install`, tested separately)
- Tool configuration (that's post-install)
- User modifications (that's ongoing use)
- Complex scenarios (those are integration tests)

### Test Categories for Installation

**Static Tests** (Instant):

- Syntax validation of installer script
- Configuration schema validation

**Unit Tests** (Seconds):

- Git identity detection logic
- Backup configuration parsing
- Commit message generation from state diff

**Installation Tests** (Minutes, VM-based):

- Complete installation flow on fresh system
- Each question/response path
- Error handling during installation
- Backup initialization
- Success screen verification

**Real-World Tests** (Hours, actual systems):

- Fresh Ubuntu VPS installation
- Fresh macOS installation
- GitHub backup setup works end-to-end
- Tailscale setup works end-to-end
- Restore from backup on new machine

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
- And backup repo is initialized
- And they see success message
- And they can start using Cafaye

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

- [ ] Logo display
- [ ] System detection
- [ ] Requirements validation
- [ ] Error messages

### Plan Phase

- [ ] Welcome message
- [ ] Git identity detection/collection
- [ ] Backup strategy (GitHub walkthrough)
- [ ] Secure access (Tailscale setup)
- [ ] Editor selection (with distribution submenu)
- [ ] Theme selection
- [ ] SSH keys (VPS only)
- [ ] Auto-shutdown (VPS only)

### Confirm Phase

- [ ] Summary generation
- [ ] Summary display
- [ ] Confirmation prompt
- [ ] Modify/restart/exit options

### Execute Phase

- [ ] Progress tracking
- [ ] Step-by-step execution
- [ ] Error handling
- [ ] Warning display
- [ ] Time estimation

### Backup Initialization

- [ ] Git repo initialization
- [ ] Git identity configuration
- [ ] Remote configuration
- [ ] Initial commit
- [ ] Push (if strategy is immediate)

### Post-Install

- [ ] Success screen
- [ ] Tool addition examples
- [ ] Quick start commands
- [ ] Documentation links

### Technical

- [ ] TUI elements
- [ ] Single directory structure
- [ ] State persistence
- [ ] Logging
- [ ] Signal handling
- [ ] Idempotency
- [ ] Exit codes

### Module System

- [ ] Module template at `modules/_template.nix`
- [ ] Module auto-discovery from `modules/` directory
- [ ] Each module self-contained with meta information
- [ ] Dependency resolution between modules

### Test Structure (1:1 Mapping)

- [ ] Tests directory mirrors modules directory exactly
- [ ] Every module has corresponding test file
- [ ] Test path: `tests/modules/<category>/<name>.nix` for `modules/<category>/<name>.nix`
- [ ] Module creation template includes test file template
- [ ] CI enforces 1:1 mapping (fails if module lacks test)

### Testing (Installation Only)

- [ ] Installation flow tests
- [ ] Git identity collection tests
- [ ] Backup setup tests
- [ ] Secure access tests
- [ ] Editor selection tests
- [ ] Confirmation tests
- [ ] Execution tests
- [ ] Backup initialization tests
- [ ] Error handling tests
- [ ] Idempotency tests

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
✅ Zsh + Starship
✅ Neovim + LazyVim
✅ Backup configured
✅ Tailscale connected

Add your tools:
  caf install ruby rails
  caf install nodejs
  caf install claude-code

☕ ~
```

**Total time:** 2-3 minutes  
**Total questions:** 6 (all with sensible defaults)  
**User actions:** Mostly pressing Enter to accept defaults
