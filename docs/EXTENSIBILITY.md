# Extensibility Model

Cafaye supports extension without forcing long-lived forks.

## Principles
- Keep Cafaye defaults in `config/cafaye/`.
- Keep user customizations in `config/user/`.
- Add user scripts/hooks/extensions in user-owned paths.
- Prefer overlays/extensions over patching core files.

## Extension Points
- User tmux workspace definitions (`config/user/tmux/`).
- User zsh customizations (`config/user/zsh/`).
- User editor overrides (`config/user/nvim/*`).
- Hooks and menu extensions (`~/.config/cafaye/hooks`, `~/.config/cafaye/extensions`).

## Compatibility Contract
- Core module interfaces should stay backward compatible across minor upgrades.
- Deprecated behavior should include migration windows and guidance.
- Breaking changes must be documented in release notes.
