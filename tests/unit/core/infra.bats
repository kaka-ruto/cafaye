#!/usr/bin/env bats

load "../../lib/test_helper"

@test "zsh default config enables Cafaye tmux auto-attach" {
  run rg -n "CAFAYE_AUTO_TMUX|exec tmux attach -t" config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]
}

@test "astronvim notre plugin is remote-safe (not hardcoded local dir)" {
  run rg -n "kaka-ruto/notre.nvim" config/user/nvim/astronvim/plugins/notre.lua
  [ "$status" -eq 0 ]

  run rg -n "dir\\s*=\\s*\"~/" config/user/nvim/astronvim/plugins/notre.lua
  [ "$status" -ne 0 ]
}

@test "workspace boot uses declarative runner and user-overridable config" {
  run rg -n "caf-workspace-run" cli/scripts/caf-workspace-init
  [ "$status" -eq 0 ]

  run rg -n "workspace\\.yml|parse_workspace_yaml|CAF_WORKSPACE_WINDOWS" cli/scripts/caf-workspace-run
  [ "$status" -eq 0 ]

  run rg -n "session:|start_window:|windows:" config/user/tmux/workspace.yml
  [ "$status" -eq 0 ]

  run rg -n "config/user/tmux/workspace.sh|config/user/tmux/workspace.yml|CAF_WORKSPACE_WINDOWS" config/user/tmux/workspace.sh
  [ "$status" -eq 0 ]
}

@test "zsh leader/alt keybindings and search command are present" {
  run rg -n "CAFAYE_LEADER_KEY|CAFAYE_LEADER_TIMEOUT_MS|CAFAYE_DOUBLE_TAP_MS|bindkey '\\\\em'|bindkey '\\\\ec'|bindkey '\\\\es'|bindkey '\\\\er'|bindkey '\\\\ed'" config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]

  run rg -n "caf-search|run_caf|CLI_MAIN" cli/scripts/caf-search config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]
}

@test "neovim distro templates and user override files exist" {
  run test -f config/cafaye/nvim/astronvim/init.lua
  [ "$status" -eq 0 ]
  run test -f config/cafaye/nvim/lazyvim/init.lua
  [ "$status" -eq 0 ]
  run test -f config/cafaye/nvim/nvchad/init.lua
  [ "$status" -eq 0 ]

  run test -f config/user/nvim/lazyvim/autocmds.lua
  [ "$status" -eq 0 ]
  run test -f config/user/nvim/nvchad/options.lua
  [ "$status" -eq 0 ]
  run test -f config/user/nvim/nvchad/plugins.lua
  [ "$status" -eq 0 ]
  run test -f config/user/nvim/nvchad/configs/lspconfig.lua
  [ "$status" -eq 0 ]
}

@test "neovim modules wire user config symlinks" {
  run rg -n "nvim/lua/user|force = true" modules/editors/neovim/astronvim.nix
  [ "$status" -eq 0 ]

  run rg -n "autocmds.lua" modules/editors/neovim/lazyvim.nix
  [ "$status" -eq 0 ]

  run rg -n "nvim/lua/custom" modules/editors/neovim/nvchad.nix
  [ "$status" -eq 0 ]
}

@test "fleet status has current-node visual indicator" {
  run rg -n "\\[current\\]|local_node|hostname -s" cli/scripts/caf-fleet
  [ "$status" -eq 0 ]
}

@test "installer provisions standard symlinks for tmux ghostty and zshrc" {
  run rg -n "create_standard_symlinks|safe_symlink" install.sh
  [ "$status" -eq 0 ]

  run rg -n "\\.config/cafaye/config/cafaye/tmux|\\.config/cafaye/config/cafaye/ghostty|\\.config/cafaye/config/cafaye/zsh/\\.zshrc" install.sh
  [ "$status" -eq 0 ]
}

@test "installer includes ghostty auto-launch behavior" {
  run rg -n "auto_launch_workspace|open -a Ghostty|ghostty -e bash -lc 'caf-workspace-init --attach'" install.sh
  [ "$status" -eq 0 ]
}

@test "menu system supports vim keys arrows search and submenu back/select" {
  run rg -n "caf_choose_menu|fzf|j:down|k:up|up:up|down:down|h:abort|l:accept|/:change-prompt" cli/main.sh
  [ "$status" -eq 0 ]
}

@test "ghostty config includes super-key shortcut bridge" {
  run rg -n "global:super\\+m|global:super\\+c|global:super\\+s|global:super\\+r|global:super\\+d|text:\\\\x1b" config/cafaye/ghostty/config
  [ "$status" -eq 0 ]
}

@test "style menu supports theme live preview workflow" {
  run rg -n "preview_theme_change|Previewing|Keep this theme|caf-hook-run theme-set" cli/main.sh
  [ "$status" -eq 0 ]
}
