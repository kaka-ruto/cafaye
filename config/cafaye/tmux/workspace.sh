# Cafaye default workspace definition.
# User overrides should go in: ~/.config/cafaye/config/user/tmux/workspace.sh

CAF_WORKSPACE_SESSION="${CAF_WORKSPACE_SESSION:-cafaye}"
CAF_WORKSPACE_START_WINDOW="${CAF_WORKSPACE_START_WINDOW:-terminal}"
CAF_WORKSPACE_WINDOWS=(
  "dashboard|clear; command -v fastfetch >/dev/null 2>&1 && fastfetch || echo 'Cafaye dashboard'"
  "terminal|"
  "git|command -v lazygit >/dev/null 2>&1 && lazygit || echo 'lazygit unavailable on PATH'"
)
