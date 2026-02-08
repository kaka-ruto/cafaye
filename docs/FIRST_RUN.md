# First Run Setup

After installation, log into your new Cafaye OS machine and run the setup wizard:

```bash
caf-setup
```

## What it does

The `caf-setup` wizard is an interactive TUI (Terminal User Interface) that guides you through:

1. **Editor Selection**
   - Choose between **Neovim** (default), **Helix**, or **VS Code Server**.
   - If Neovim, select a distribution: **LazyVim**, **AstroNvim**, **NvChad**, or **LunarVim**.

2. **Language Support**
   - Enable development environments for **Python**, **Ruby**, **Go**, **Rust**, **Node.js**, **PHP**, and **Java**.

3. **AI Features**
   - Choose to enable local AI features (Ollama, Aider, Continue) if hardware supports it.

## Applying Changes

Once configured, the wizard will:
1. Update your local `user-state.json` configuration.
2. Run `caf-system-update`, which rebuilds the system configuration.
3. Reload your shell and environment.

## Verification

To verify your setup:
- Run `caf-system-doctor` to check system health.
- Run `caf-about-show` to see system details.
- Launch your editor with `caf-editor-launch`.
