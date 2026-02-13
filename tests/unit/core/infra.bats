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
  run rg -n "CAFAYE_LEADER_KEY|CAFAYE_LEADER_TIMEOUT_MS|CAFAYE_DOUBLE_TAP_MS|bindkey '\\\\em'|bindkey '\\\\es'|bindkey '\\\\er'|bindkey '\\\\ed'" config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]

  run rg -n "caf-search" cli/scripts/caf-search config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]
}
