#!/usr/bin/env bats

load "../../lib/test_helper"

@test "tat fails with clear error when tmux is unavailable" {
  PATH="/usr/bin:/bin" run config/cafaye/bin/tat
  [ "$status" -eq 1 ]
  [[ "$output" == *"tmux is required"* ]]
}

@test "tm fails with clear error when tmux is unavailable" {
  PATH="/usr/bin:/bin" run config/cafaye/bin/tm
  [ "$status" -eq 1 ]
  [[ "$output" == *"tmux is required"* ]]
}

@test "extract requires an archive argument" {
  run config/cafaye/bin/extract
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: extract <archive>"* ]]
}

@test "killport requires numeric argument" {
  run config/cafaye/bin/killport abc
  [ "$status" -eq 1 ]
  [[ "$output" == *"Port must be numeric."* ]]
}

@test "git-sync fails outside git repository" {
  run config/cafaye/bin/git-sync
  [ "$status" -eq 1 ]
  [[ "$output" == *"inside a git repository"* ]]
}

@test "git-clean-branches fails outside git repository" {
  run config/cafaye/bin/git-clean-branches
  [ "$status" -eq 1 ]
  [[ "$output" == *"inside a git repository"* ]]
}
