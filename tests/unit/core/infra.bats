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
