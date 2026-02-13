# Migration Guide: Moving to Cafaye OS

This guide helps you migrate from common dotfile managers or development environment setups to Cafaye.

## 1. Migrating from Custom Dotfiles

If you already have personalized dotfiles (zsh, tmux, nvim, etc.), Cafaye allows you to keep them while benefiting from its automated infrastructure.

### Approach A: The Custom Overlay (Recommended)
The easiest way is to copy your specific configurations into `~/.config/cafaye/config/user/`.

- **Zsh Aliases/Functions**: Move them to `~/.config/cafaye/config/user/zsh/custom.zsh`. These are loaded *after* Cafaye's defaults, so they will override them.
- **Tmux Keybindings**: Put them in `~/.config/cafaye/config/user/tmux/custom.conf`. 
- **Neovim**: If you use a custom setup, place it in `~/.config/cafaye/config/user/nvim/`. If you use AstroNvim, follow the AstroNvim-specific layout in that directory.

### Approach B: Symlinking Existing Repos
If you want to keep your dotfiles in their own repository:
1. Delete the default directories in `~/.config/cafaye/config/user/`.
2. Symlink your local repos into that location.
   ```bash
   ln -s ~/src/my-zsh-config ~/.config/cafaye/config/user/zsh
   ```

## 2. Migrating from asdf / rbenv / pyenv

Cafaye uses **mise** (a faster asdf compatible tool) to manage language runtimes.

1. **Uninstall your existing managers**: Remove `asdf`, `rbenv`, etc., from your `.zshrc`.
2. **Move your version files**: Mise automatically picks up `.tool-versions`, `.ruby-version`, `.node-version`.
3. **Install with mise**:
   ```bash
   mise install
   ```
4. **Cafaye Integration**: When you run `caf install <lang>`, Cafaye ensures the corresponding mise plugin is active and configured in your shell.

## 3. Migrating from Homebrew (macOS)

Cafaye doesn't replace Homebrew, but it reduces your dependency on it for CLI tools.

- **Nix vs Brew**: We recommend using Nix for CLI tools (managed via `home.nix`) and Brew for GUI applications (Casks).
- **Tool Duplication**: If you have `ripgrep`, `fd`, or `bat` installed via Brew, you can safely uninstall them and let Cafaye manage them via Nix.

## 4. Migrating from VS Code / Manual Setups

If you are coming from a manual setup on a VPS:
1. **Inventory**: Make a list of your manually installed packages.
2. **Declarative Transition**: Add these packages to `home.nix` in the `home.packages` section.
3. **Apply**: Run `caf apply` to ensure they are managed by Nix.

## 5. Cleaning Up

After migrating, check for conflicts:
```bash
caf-system-doctor
```
This utility will identify if any old configuration files are interfering with Cafaye's managed environment.
