# Cafaye managed zsh entrypoint.
# This file exists so ~/.zshrc can be symlinked to a stable path.

source "$HOME/.config/cafaye/config/cafaye/zsh/config.zsh"
if [[ -f "$HOME/.config/cafaye/config/user/zsh/custom.zsh" ]]; then
  source "$HOME/.config/cafaye/config/user/zsh/custom.zsh"
fi
