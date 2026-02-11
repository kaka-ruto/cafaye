# Cafaye Installation Behavior Specification

This document specifies the exact installation flow and user experience for the Cafaye installer (`install.sh`).

## Overview

The installer follows a **Plan → Confirm → Execute** pattern:

1. **Plan**: Collect minimum required information from the user
2. **Confirm**: Show summary and get explicit confirmation
3. **Execute**: Install everything to completion

**Design Principle:** We install the **foundation** only. Languages, frameworks, AI tools, and other software are installed later by the user using `caf install <tool>`.

## Installation Flow

### PRE-INSTALLATION EXPERIENCE

**Goal:** Captivate the user immediately and set expectations.

**Visual Experience:**
- [ ] Clear terminal screen
- [ ] Display stunning ASCII art logo (animated or static with colors)
- [ ] Show tagline: "The first Development Runtime built for collaboration between humans and AI"
- [ ] Display version number
- [ ] Show beautiful loading animation while detecting system

**System Detection (2-3 seconds):**
- [ ] Detect operating system (macOS/Ubuntu/Debian)
- [ ] Detect architecture (x86_64/aarch64)
- [ ] Check available disk space (need 2GB+)
- [ ] Check internet connectivity
- [ ] Verify minimum requirements met

**If requirements not met:**
- [ ] Show clear, friendly error message
- [ ] Explain what's missing
- [ ] Provide specific fix instructions
- [ ] Exit gracefully

**Requirements Check Display:**
```
☕ Cafaye Development Runtime
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Detecting your system...

✓ Operating System: macOS 14.2
✓ Architecture: Apple Silicon (arm64)
✓ Disk Space: 245GB available
✓ Internet: Connected
✓ Memory: 16GB

✅ Your system is ready!

Press Enter to continue...
```

---

### PHASE 1: PLAN (Information Collection)

**Goal:** Collect ONLY minimum required data for a successful foundation setup.

**Design Principle:** Everything else can be installed later with `caf install`. We focus on the core runtime only.

**Section 1: Welcome & Context**
- [ ] Welcome message explaining what Cafaye is
- [ ] Explain this will take 2-3 minutes for the foundation
- [ ] Promise: "We'll set up the foundation. You add your tools later with: caf install <tool>"

**Section 2: Configuration (Optional, with defaults)**

**We only ask for:**

```
Quick Configuration (Enter to accept defaults):

📁  Projects directory: [~/projects] >
🎨  Theme: [Catppuccin Mocha] >
⌨️   Shell: [Zsh with Starship] >
```

- [ ] Projects directory (default: ~/projects)
- [ ] Theme selection (default: Catppuccin Mocha)
- [ ] Shell preference (default: Zsh with Starship)
- [ ] All have sensible defaults, user can just press Enter
- [ ] Make clear these can be changed later with `caf config`

**What we DON'T ask for (install later):**
- ❌ Programming languages (Ruby, Python, Node, etc.) - Install with `caf install ruby`
- ❌ Frameworks (Rails, Django, Next.js) - Install with `caf install rails`
- ❌ Databases (PostgreSQL, Redis) - Install with `caf install postgresql`
- ❌ AI tools (Claude Code, Aider, Ollama) - Install with `caf install claude-code`
- ❌ Code editor details (Neovim distributions) - Install with `caf install neovim`
- ❌ Complex configuration - Configure later with `caf setup`

**Section 3: SSH Keys (VPS only, optional)**

```
SSH Key Setup (optional):

🔑  Import SSH keys for server access?

[✓] From SSH agent (3 keys found)
[ ] From file: ~/.ssh/id_ed25519.pub
[ ] Paste manually
[ ] Skip (configure later)
```

- [ ] Auto-detect SSH agent keys
- [ ] Allow user to select which keys to import
- [ ] Allow skip (can configure later)
- [ ] This is ONLY for VPS installations

---

### PHASE 2: CONFIRM (Review & Approval)

**Goal:** Show summary and get explicit user confirmation.

**Summary Screen:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 Installation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  Foundation to be installed:
    • Nix package manager
    • Home Manager
    • Zsh with Starship prompt
    • Terminal tools (zellij, fzf, etc.)
    • Catppuccin Mocha theme

📁  Configuration:
    • Projects directory: ~/projects
    • Theme: Catppuccin Mocha
    • Shell: Zsh with Starship

🔐  SSH Keys:
    • 2 keys imported

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💾  This will use approximately 500MB of disk space
⏱️   Installation will take 2-3 minutes
🔄  You can add languages, frameworks, and tools later with: caf install <tool>

Ready to install the foundation? [Y/n]
```

**Confirmation Requirements:**
- [ ] Show minimal, focused data
- [ ] Display disk space requirement
- [ ] Display estimated time
- [ ] Remind user they install tools later
- [ ] Require explicit [Y/n] confirmation (default to Y)
- [ ] If 'n', offer to go back and modify or exit

---

### PHASE 3: EXECUTE (Installation)

**Goal:** Execute flawlessly with beautiful, informative progress display.

**Progress Display Style:**
- [ ] Show current step with spinner/animation
- [ ] Show progress bar for overall completion
- [ ] Show estimated time remaining
- [ ] Use emoji indicators for status:
  - 🔄 In progress
  - ✅ Complete
  - ⏭️ Waiting
  - ⚠️ Warning (but continuing)

**Installation Steps:**

```
Installing Cafaye Foundation...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[████░░░░░░░░░░░░░░░░] 30% - About 2 minutes remaining

✅ System check complete
✅ Nix package manager installed
🔄 Installing Home Manager... (current)
⏭️  Configuring shell
⏭️  Setting up themes
⏭️  Finalizing

💡 Tip: Add tools anytime with: caf install <tool>
   Examples: caf install ruby rails postgresql
```

**Detailed Step Breakdown:**

1. **System Preparation** (10 seconds)
   - [ ] Update package lists (if needed)
   - [ ] Create cafaye directories
   - [ ] Check permissions

2. **Nix Installation** (1-2 minutes)
   - [ ] Download Nix installer
   - [ ] Run multi-user installation
   - [ ] Configure nix.conf
   - [ ] Enable flakes

3. **Home Manager Installation** (30 seconds)
   - [ ] Install Home Manager
   - [ ] Generate initial config
   - [ ] Set up user profile

4. **Foundation Tools Installation** (30 seconds)
   - [ ] Download base packages
   - [ ] Install Zsh and Starship
   - [ ] Install terminal tools (zellij, fzf, zoxide, etc.)
   - [ ] Install theme files

5. **Configuration** (20 seconds)
   - [ ] Generate user-state.json
   - [ ] Set up dotfiles
   - [ ] Configure shell
   - [ ] Set up themes

6. **Verification** (10 seconds)
   - [ ] Verify tools installed correctly
   - [ ] Run smoke tests
   - [ ] Check for errors

**Error Handling During Installation:**
- [ ] If step fails, show clear error message
- [ ] Offer to retry, skip, or abort
- [ ] Log full error details to /tmp/cafaye-install.log
- [ ] Provide helpful troubleshooting tips
- [ ] Never leave system in broken state

---

### POST-INSTALLATION EXPERIENCE

**Goal:** Celebrate success and show how to add tools.

**Success Screen (Beautiful & Inspiring):**

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
    ✅ Catppuccin Mocha theme

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯  Quick Start:

    Start terminal:      zellij
    Main menu:           caf
    View config:         cat ~/.config/home-manager/home.nix

🛠️   Add Your Tools:

    Install Ruby:        caf install ruby
    Install Rails:       caf install rails postgresql redis
    Install Node:        caf install nodejs
    Install AI tools:    caf install claude-code
    
    Or all at once:      caf install ruby rails postgresql aider

📦  Available tools:    caf search <name>
    Full setup wizard:   caf setup

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡  Pro Tips:

    View all tools:      caf search
    Backup config:       caf export ~/backup.tar.gz
    Get help:            caf --help

📚  Documentation:  https://github.com/kaka-ruto/cafaye

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎊  Happy coding! Your environment is perfectly reproducible.

    "The first Development Runtime built for 
     collaboration between humans and AI."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Press Enter to start coding...
```

**Post-Installation Actions:**
- [ ] Offer to start a new shell immediately
- [ ] Show `caf doctor` command for verification
- [ ] Remind about `caf install` for adding tools
- [ ] Mention `caf setup` for full configuration wizard
- [ ] Encourage starring the GitHub repo

**If installation was on VPS:**
- [ ] Show connection instructions clearly
- [ ] Remind about Tailscale (if configured)
- [ ] Show SSH command to reconnect
- [ ] Mention auto-shutdown if enabled

---

## Behavior-Driven Testing

**Core Principle:** We test **behaviors**, not implementation details, not frameworks, not specific tools.

### What We Test

**We test THAT:**
- ✅ The installer starts and displays correctly
- ✅ The installer collects required information
- ✅ The installer confirms before executing
- ✅ The installer completes successfully
- ✅ The user can add tools after installation
- ✅ The configuration can be modified
- ✅ The environment is reproducible

**We do NOT test:**
- ❌ Specific Nix implementation details
- ❌ Specific Home Manager configurations
- ❌ Whether Ruby 3.3.2 vs 3.3.3 is installed
- ❌ Specific tool versions (test "Ruby is installed", not "Ruby 3.3.0")
- ❌ Internal file structures
- ❌ Specific gum UI library behavior

### Test Categories

**1. Behavioral Tests (What the user experiences)**

```bash
# Test: User can install foundation
test_installer_completes() {
  # Given: Fresh Ubuntu system
  # When: Run installer
  run_installer
  # Then: Installation completes successfully
  assert_exit_code 0
  assert_caf_command_exists
  assert_nix_command_exists
  assert_home_manager_exists
}

# Test: User can add tools after installation
test_user_can_add_tools() {
  # Given: Installed Cafaye
  install_cafaye
  # When: User runs caf install
  run "caf install ruby"
  # Then: Tool is available
  assert_command_exists "ruby"
  assert_command_succeeds "ruby --version"
}

# Test: User can modify configuration
test_user_can_modify_config() {
  # Given: Installed Cafaye
  install_cafaye
  # When: User changes configuration
  run "caf config --theme tokyo-night"
  run "caf apply"
  # Then: Configuration is applied
  assert_config_contains "theme.*tokyo"
}

# Test: Installation is reproducible
test_installation_is_reproducible() {
  # Given: Same configuration
  config=generate_config
  # When: Install on machine A
  install_on_machine_a "$config"
  # And: Install on machine B
  install_on_machine_b "$config"
  # Then: Both have same environment
  assert_environments_equal "machine_a" "machine_b"
}
```

**2. User Flow Tests (End-to-end scenarios)**

```bash
# Test: Fresh install flow
test_fresh_install_flow() {
  # Given: Fresh Ubuntu VPS
  fresh_vps
  
  # When: User runs installer
  output=$(run_installer << 'EOF'
    # Enter through welcome
    
    # Accept defaults for configuration
    
    # Confirm installation
    Y
EOF
)
  
  # Then: Foundation is installed
  assert_output_contains "SUCCESS! Cafaye is installed"
  assert_caf_commands_available
  
  # And: User can add Ruby
  run_on_vps "caf install ruby"
  assert_vps_command_succeeds "ruby --version"
  
  # And: User can add Node
  run_on_vps "caf install nodejs"
  assert_vps_command_succeeds "node --version"
}

# Test: Local macOS install
test_local_macos_install() {
  # Given: Fresh macOS
  fresh_macos
  
  # When: Run installer
  run_installer
  
  # Then: Foundation installed
  assert_caf_installed
  
  # And: User can use immediately
  assert_command_succeeds "caf --help"
  assert_command_succeeds "zellij --version"
}
```

**3. Error Behavior Tests**

```bash
# Test: Installer handles missing disk space gracefully
test_installer_handles_no_disk_space() {
  # Given: System with < 1GB free
  setup_low_disk_space
  
  # When: Run installer
  output=$(run_installer)
  
  # Then: Shows clear error
  assert_output_contains "Not enough disk space"
  assert_output_contains "Need at least 2GB"
  
  # And: Exits gracefully
  assert_exit_code 5
}

# Test: User can cancel and resume
test_user_can_cancel() {
  # Given: Installer running
  start_installer
  
  # When: User presses Ctrl+C
  send_signal SIGINT
  
  # Then: Shows cancellation message
  assert_output_contains "Installation cancelled"
  
  # And: System is not broken
  assert_system_stable
}
```

### Test Implementation Strategy

**Unit Tests (Fast, test logic):**
- Test CLI command parsing
- Test state management
- Test configuration validation

**Integration Tests (Medium, test systems):**
- Test module loading
- Test tool installation
- Test configuration application

**Behavioral Tests (VM-based, test user experience):**
- Test complete installation flow
- Test tool addition flow
- Test configuration modification
- Test error scenarios

**Real-World Tests (Slow, test actual VPS):**
- Test on fresh Ubuntu VPS
- Test on fresh macOS
- Test backup/restore
- Test cross-platform compatibility

### Example Test File Structure

```
tests/
├── unit/
│   ├── cli/
│   │   ├── command-parsing.bats
│   │   └── state-management.bats
│   └── lib/
│       └── module-registry.bats
│
├── integration/
│   ├── core/
│   │   ├── nix-installation.nix
│   │   └── home-manager-setup.nix
│   ├── modules/
│   │   ├── ruby-installation.nix
│   │   └── nodejs-installation.nix
│   └── behaviors/
│       ├── user-adds-tool.nix
│       └── user-modifies-config.nix
│
└── real-world/
    ├── vps/
    │   ├── ubuntu-2404-install.sh
    │   └── debian-12-install.sh
    └── local/
        ├── macos-install.sh
        └── ubuntu-local-install.sh
```

### Test Writing Guidelines

**DO:**
- ✅ Test what the user experiences
- ✅ Test behaviors, not implementations
- ✅ Use clear, descriptive test names
- ✅ Test success AND failure scenarios
- ✅ Test edge cases
- ✅ Keep tests independent

**DON'T:**
- ❌ Test internal implementation details
- ❌ Test specific versions of tools
- ❌ Test that specific files exist at specific paths
- ❌ Test library internals (gum, nix, etc.)
- ❌ Make tests dependent on each other
- ❌ Test things users don't care about

### Running Tests

```bash
# Run all tests
./bin/test.sh

# Run only behavioral tests
caf-test behavior

# Run specific behavior test
caf-test behavior --test user-can-add-tools

# Run with verbose output
caf-test behavior --verbose

# Run on remote forge
caf-test behavior --remote
```

---

## Technical Requirements

### Visual/UX Requirements

- [ ] Use `gum` for all interactive TUI elements
- [ ] Support both light and dark terminal themes
- [ ] Handle terminal resize gracefully
- [ ] Support arrow keys, Tab, Enter, Space for navigation
- [ ] Support Ctrl+C to cancel (with confirmation)
- [ ] Clear screen appropriately but preserve scrollback
- [ ] Use colors consistently:
  - Green: Success, completion
  - Yellow: Warnings, tips
  - Red: Errors (only when blocking)
  - Blue: Information, progress
  - Purple/Magenta: Brand accent color

### Data Collection Requirements

**Minimum required:**
- [ ] Configuration: project directory, theme, shell (all have defaults)
- [ ] Confirmation to proceed

**Optional:**
- [ ] SSH keys (for VPS only, can skip)

**NOT asked:**
- [ ] Languages, frameworks, databases, AI tools
- [ ] Complex configuration

### State Management

- [ ] Write collected data to `/tmp/cafaye-install-state.json`
- [ ] On completion, move to `~/.config/cafaye/install-state.json`
- [ ] On failure, preserve state for debugging

### Logging

- [ ] Log all output to `/tmp/cafaye-install.log`
- [ ] Include timestamps
- [ ] Include commands executed
- [ ] Include error details
- [ ] Rotate logs (keep last 5)

### Idempotency

- [ ] Running installer again should detect existing installation
- [ ] Offer to:
  - Reconfigure (`caf setup`)
  - Update (`caf update`)
  - Reinstall (clean slate)
  - Exit

### Exit Codes

- [ ] 0: Success
- [ ] 1: General error
- [ ] 2: Requirements not met
- [ ] 3: User cancelled
- [ ] 4: Network error
- [ ] 5: Disk space error

---

## Implementation Checklist

### Pre-Install Experience
- [ ] ASCII art logo display
- [ ] System detection logic
- [ ] Requirements validation
- [ ] Beautiful error messages for failures

### Plan Phase
- [ ] Welcome message
- [ ] Configuration UI (minimal, with defaults)
- [ ] SSH key detection (VPS only, optional)

### Confirm Phase
- [ ] Summary generation (focused on foundation only)
- [ ] Beautiful summary display
- [ ] Confirmation prompt
- [ ] Modify/restart/exit options

### Execute Phase
- [ ] Progress tracking system
- [ ] Step-by-step execution
- [ ] Error handling and recovery
- [ ] Warning display (non-blocking)
- [ ] Time estimation

### Post-Install Experience
- [ ] Success screen with celebration
- [ ] Clear message about adding tools later
- [ ] Examples of caf install commands
- [ ] Quick start commands
- [ ] Documentation links

### Technical
- [ ] Gum integration for all UI
- [ ] State persistence
- [ ] Logging system
- [ ] Signal handling (Ctrl+C)
- [ ] Idempotency logic
- [ ] Exit code handling

### Testing
- [ ] Behavioral tests for installation
- [ ] Behavioral tests for tool addition
- [ ] Behavioral tests for configuration
- [ ] Error scenario tests
- [ ] Cross-platform tests

---

## Example Minimal Session

```bash
$ curl -fsSL https://cafaye.sh | bash

[Screen clears]

☕ Cafaye Development Runtime v0.1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        ╭─────────────────╮
        │   ☕ CAFAYE     │
        │                 │
        │  Development    │
        │    Runtime      │
        ╰─────────────────╮

The first Development Runtime built for
   collaboration between humans and AI.

Detecting your system... ✓

✓ macOS 14.2 (Apple Silicon)
✓ 245GB disk space available
✓ 16GB memory
✓ Internet connected

Press Enter to continue...

[Enter pressed]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Welcome! Let's set up your foundation.

We'll install the core runtime. You add 
your tools later with: caf install <tool>

This will take 2-3 minutes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quick Configuration (Enter for defaults):

📁 Projects directory: [~/projects] >
🎨 Theme: [Catppuccin Mocha] >
⌨️  Shell: [Zsh with Starship] >

[User accepts defaults]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 Installation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  Foundation:
    • Nix + Home Manager
    • Zsh with Starship
    • Terminal tools
    • Catppuccin theme

💾 500MB disk space
⏱️  2-3 minutes
🛠️  Add tools later: caf install <tool>

Ready? [Y/n] >

[User presses Enter]

Installing Cafaye Foundation...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[████████████████████] 100%

🎉 SUCCESS!

Foundation installed:
✅ Nix + Home Manager
✅ Zsh + Starship
✅ Terminal tools

Add your tools:
  caf install ruby rails
  caf install nodejs
  caf install claude-code

Start coding:
  zellij
  caf

Happy coding! ☕

☕ ~ 
```
