# Cafaye Installation Behavior Specification

This document describes the behaviors we expect from the Cafaye installer. We describe WHAT should happen, not HOW it's implemented.

## Philosophy

**We install the foundation only.** The installer sets up the core runtime (Nix, Home Manager, shell, basic tools). Everything else—languages, frameworks, AI tools—is added later by the user using `caf install <tool>`.

**Why:** This keeps installation fast (2-3 minutes), simple (minimal questions), and flexible (users add what they need, when they need it).

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
- Available disk space
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

**Purpose:** Collect only the information needed to install the foundation.

**Welcome Section:**
- Display welcome message explaining Cafaye
- State that installation takes 2-3 minutes
- Promise: "We'll set up the foundation. You add your tools later."

**Configuration Section:**
The installer asks for three configuration options, all with sensible defaults:

1. **Projects directory** - Where user stores code (default: ~/projects)
2. **Theme** - Visual theme for terminal (default: Catppuccin Mocha)
3. **Shell** - Shell environment (default: Zsh with Starship)

Each option shows the default value. The user can press Enter to accept defaults or type a custom value. The installer makes clear these can be changed later.

**SSH Keys Section (VPS only):**
For VPS installations, optionally import SSH keys:
- Detect keys from SSH agent automatically
- Allow selection of which keys to import
- Provide option to specify key file path
- Provide option to paste key manually
- Allow skip with "configure later" option

**What We DON'T Ask:**
- Programming languages (Ruby, Python, Node, etc.)
- Web frameworks (Rails, Django, Next.js)
- Databases (PostgreSQL, Redis)
- AI tools (Claude Code, Aider, Ollama)
- Code editor distributions
- Complex configuration

All of these are installed later using `caf install <tool>`.

---

## Phase 2: Confirm

**Purpose:** Show what will be installed and get user approval.

**Summary Display:**
The installer shows a clear summary including:
- What will be installed (foundation components)
- Configuration choices (directory, theme, shell)
- SSH keys imported (if applicable)
- Disk space required (approximately 500MB)
- Estimated time (2-3 minutes)
- Reminder that tools can be added later

**Confirmation Prompt:**
The installer asks: "Ready to install the foundation? [Y/n]"
- Default is "Y" (user can just press Enter)
- If user selects "n", offer options to:
  - Go back and modify selections
  - Start over
  - Exit installer

---

## Phase 3: Execute

**Purpose:** Install the foundation with clear progress indication.

**Progress Display:**
The installer shows:
- Overall progress bar (0-100%)
- Current step with visual indicator
- Estimated time remaining
- List of completed steps (with checkmarks)
- Current step (with spinner)
- Upcoming steps (grayed out)
- Occasional helpful tips

**Installation Steps:**
The installer proceeds through these steps:

1. System Preparation - Update package lists, create directories
2. Nix Installation - Install Nix package manager
3. Home Manager Installation - Install Home Manager
4. Foundation Tools Installation - Install shell, terminal tools, themes
5. Configuration - Generate config files, set up dotfiles
6. Verification - Verify installation succeeded

**Error Handling:**
If any step fails:
- Show clear error message explaining what happened
- Offer options: Retry, Skip, or Abort
- Log detailed error information for debugging
- Never leave the system in a broken state

**Warnings:**
Non-blocking issues are shown in yellow with explanation, but installation continues.

**Timing:** Total installation takes 2-3 minutes.

---

## Post-Installation Experience

**Purpose:** Celebrate success and guide user to next steps.

**Success Display:**
The installer shows a beautiful success screen including:
- Celebration message with ASCII art
- Summary of what was installed (foundation components)
- Quick start commands
- Examples of how to add tools using `caf install`
- How to find available tools using `caf search`
- How to run the full setup wizard using `caf setup`
- How to backup the configuration
- Where to find documentation

The success screen emphasizes that the user can now add their specific tools.

**Next Steps:**
The installer offers to start a new shell immediately. After installation, the user can:
- Start working: `zellij`
- Access menu: `caf`
- Add tools: `caf install <tool>`
- Run setup wizard: `caf setup`
- Verify installation: `caf doctor`

**VPS Specific:**
If installed on VPS, show:
- How to reconnect via SSH
- Tailscale connection info (if configured)
- Auto-shutdown reminder (if enabled)

---

## Testing Behaviors

We test **what the user experiences**, not how it's implemented.

### Behavioral Tests

These tests verify that users can:

**Installation:**
- Run the installer on a fresh system
- See a welcome screen with system detection
- Accept defaults or customize configuration
- See a summary and confirm installation
- Watch progress as foundation installs
- See a success message when complete
- Start using Cafaye immediately

**Tool Addition:**
- Add tools after installation using `caf install`
- Install single tools: `caf install ruby`
- Install multiple tools: `caf install ruby rails postgresql`
- Have the tool available immediately after installation
- Use the tool without restarting the shell

**Configuration:**
- Modify configuration using `caf config`
- Apply configuration changes using `caf apply`
- See changes take effect immediately
- Change theme, shell, or other settings

**Reproducibility:**
- Export their configuration
- Import configuration on a new machine
- Get identical environment on the new machine
- Share configuration with others

**Error Handling:**
- See clear error messages when things go wrong
- Have the option to retry, skip, or abort
- Not have their system broken by failed installation
- Cancel installation gracefully with Ctrl+C

### What We Test

**User Experiences:**
- User can install Cafaye foundation
- User can add tools after installation
- User can modify configuration
- User can export and import their environment
- User sees clear errors when things fail

### What We Don't Test

**Implementation Details:**
- Specific Nix code structures
- Specific Home Manager configurations
- Exact file paths where things are stored
- Specific versions of tools (test "Ruby works" not "Ruby 3.3.2")
- Internal state management
- Specific UI library behaviors

### Test Categories

**Static Tests** (Instant):
- Syntax validation
- Configuration schema validation

**Unit Tests** (Seconds):
- CLI command logic
- State management logic
- Module loading logic

**Behavioral Tests** (Minutes, VM-based):
- Complete installation flow
- Tool addition flow
- Configuration modification
- Error scenarios

**Real-World Tests** (Hours, actual systems):
- Fresh Ubuntu VPS installation
- Fresh macOS installation
- Cross-platform compatibility
- Backup and restore workflows

### Test Writing Principles

**Describe behaviors, not implementations:**

Good: "User can install Ruby and run ruby --version"
Bad: "Ruby 3.3.0 is installed at /nix/store/..."

Good: "Installer shows error when disk is full"
Bad: "Function check_disk_space returns false"

Good: "User sees success message and can start coding"
Bad: "Success screen renders with gum library"

**Test the user journey:**

- Given a fresh system
- When the user runs the installer
- Then they see a welcome screen
- And they can accept defaults
- And they see installation progress
- And they see success message
- And they can start using Cafaye

**Test independence:**

Each test should be independent. Don't assume previous tests ran. Clean up before and after tests.

---

## Technical Requirements

### Visual Requirements

- Support both light and dark terminal themes
- Handle terminal resize gracefully
- Support keyboard navigation (arrow keys, Tab, Enter, Space)
- Support Ctrl+C to cancel with confirmation
- Use consistent color scheme (Green=success, Yellow=warning, Red=error, Blue=info)

### Data Collection

**Required:**
- Configuration: project directory, theme, shell (all have defaults)
- Confirmation to proceed

**Optional:**
- SSH keys (VPS only)

**Not Collected:**
- Languages, frameworks, databases, AI tools, editors

### State Management

- Store installation state temporarily during install
- Persist final state after completion
- Preserve state on failure for debugging

### Logging

- Log all output to file for debugging
- Include timestamps
- Include commands and errors
- Rotate logs (keep last 5)

### Idempotency

- Detect existing installation on re-run
- Offer: reconfigure, update, reinstall, or exit
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
- [ ] Configuration (minimal)
- [ ] SSH keys (VPS only, optional)

### Confirm Phase
- [ ] Summary generation
- [ ] Summary display
- [ ] Confirmation prompt
- [ ] Modify/restart/exit options

### Execute Phase
- [ ] Progress tracking
- [ ] Step execution
- [ ] Error handling
- [ ] Warning display
- [ ] Time estimation

### Post-Install
- [ ] Success screen
- [ ] Tool addition examples
- [ ] Quick start commands
- [ ] Documentation links

### Technical
- [ ] TUI elements
- [ ] State persistence
- [ ] Logging
- [ ] Signal handling
- [ ] Idempotency
- [ ] Exit codes

### Testing
- [ ] Installation behavior tests
- [ ] Tool addition behavior tests
- [ ] Configuration behavior tests
- [ ] Error behavior tests
- [ ] Cross-platform tests

---

## Example Session

**Minimal interaction path:**

```
$ curl -fsSL https://cafaye.sh | bash

[Logo appears with system detection]

✓ macOS detected
✓ Sufficient disk space
✓ Internet connected

Press Enter to continue...

[Welcome message]

Quick Configuration (Enter for defaults):
📁 Projects directory: [~/projects] >
🎨 Theme: [Catppuccin Mocha] >
⌨️  Shell: [Zsh with Starship] >

[User presses Enter three times]

[Summary displayed]

Ready? [Y/n] >

[User presses Enter]

[Progress bar shows installation]

[Success screen with next steps]

☕ ~ 
```

Total time: 2-3 minutes
Total questions: 3 (all with defaults)
User actions: Press Enter 5 times
