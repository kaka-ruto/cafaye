# User workspace definition (tmuxinator-lite).
# Edit this file to change what Cafaye creates on startup.
#
# Format:
#   CAF_WORKSPACE_SESSION="cafaye"
#   CAF_WORKSPACE_START_WINDOW="terminal"
#   CAF_WORKSPACE_WINDOWS=(
#     "window-name|optional startup command"
#   )
#
# Examples:
#   "editor|nvim"
#   "api|cd ~/Code/my-api && npm run dev"
#   "logs|tail -f /var/log/syslog"

CAF_WORKSPACE_SESSION="${CAF_WORKSPACE_SESSION:-cafaye}"
CAF_WORKSPACE_START_WINDOW="${CAF_WORKSPACE_START_WINDOW:-terminal}"
CAF_WORKSPACE_WINDOWS=(
  "dashboard|clear; command -v fastfetch >/dev/null 2>&1 && fastfetch || echo 'Cafaye dashboard'"
  "terminal|"
  "git|command -v lazygit >/dev/null 2>&1 && lazygit || echo 'lazygit unavailable on PATH'"
)
