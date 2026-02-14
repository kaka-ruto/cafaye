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

  run rg -n "workspace\\.yml|parse_workspace_yaml|CAF_WORKSPACE_WINDOWS|dedupe_workspace_windows|Duplicate workspace window|tmux is required" cli/scripts/caf-workspace-run
  [ "$status" -eq 0 ]

  run rg -n "session:|start_window:|windows:" config/user/tmux/workspace.yml
  [ "$status" -eq 0 ]

  run rg -n "config/user/tmux/workspace.sh|config/user/tmux/workspace.yml|CAF_WORKSPACE_WINDOWS" config/user/tmux/workspace.sh
  [ "$status" -eq 0 ]
}

@test "zsh leader/alt keybindings and search command are present" {
  run rg -n "CAFAYE_LEADER_KEY|CAFAYE_LEADER_TIMEOUT_MS|CAFAYE_DOUBLE_TAP_MS|bindkey '\\\\em'|bindkey '\\\\ec'|bindkey '\\\\es'|bindkey '\\\\er'|bindkey '\\\\ed'|bindkey '\\\\ej'" config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]

  run rg -n "caf-search|run_caf|CLI_MAIN" cli/scripts/caf-search config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]
}

@test "terminal navigation defaults and docs are present" {
  run rg -n "alias \\.\\.=|alias \\.\\.\\.=|alias \\.\\.\\.\\.=|alias -- -='cd -'|cdf\\(\\)" config/cafaye/zsh/config.zsh
  [ "$status" -eq 0 ]

  run test -f docs/TERMINAL-NAVIGATION.md
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

@test "neovim distribution setup supports plugin doctor and repair flows" {
  run rg -n "--doctor|--repair|plugin_health_check|repair_plugin_state|lazy-lock.json|Missing ~/.local/share/nvim" cli/scripts/caf-nvim-distribution-setup
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
  run rg -n "\\[current\\]|local_node|hostname -s|ip=|role=|host=" cli/scripts/caf-fleet
  [ "$status" -eq 0 ]
}

@test "fleet supports resumable sync/apply with progress and cancellation safety" {
  run rg -n "--resume|Cancel requested|\\[[0-9]+/[0-9]+\\]|fleet-apply.state|fleet-sync.state|summary: success=|trap 'cancelled=1|BatchMode=yes|IdentitiesOnly=yes|StrictHostKeyChecking=accept-new" cli/scripts/caf-fleet
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

@test "installer exposes full backup strategy options" {
  run rg -n "GitHub \\(recommended\\)|GitLab|Local only|Skip for now|Push immediately|Push daily|Push manually" install.sh
  [ "$status" -eq 0 ]
}

@test "installer secure-access options include account help and direct ssh" {
  run rg -n "Yes, help me create an account|Remind me later|No, I'll use direct SSH|NETWORK_MODE|open \"https://login.tailscale.com/start\"|xdg-open" install.sh
  [ "$status" -eq 0 ]
}

@test "installer supports ssh key import modes and no auto-shutdown path" {
  run rg -n "From SSH agent|From file: ~/.ssh/id_ed25519.pub|Paste manually|Skip \\(configure later with: caf config ssh\\)|AUTO_SHUTDOWN=.*yes.*echo.*no" install.sh
  [ "$status" -eq 0 ]
}

@test "single-vm real-world audit exists and is wired in test runner" {
  run rg -n "behavioral_realworld_gcp_single_vm\\.sh|cafaye-vps-test|us-central1-a|real-world|real-world-fleet|fleet-smoke\\.sh" tests/integration/behavioral_realworld_gcp_single_vm.sh tests/integration/real-world/fleet-smoke.sh bin/test.sh
  [ "$status" -eq 0 ]
}

@test "single behavioral nix vm test and ci workflow wiring exist" {
  run rg -n "runNixOSTest|cafaye-behavioral-single-vm|cli/scripts/caf-status|caf-workspace-run --dry-run" tests/integration/behavioral_core_single_vm.nix
  [ "$status" -eq 0 ]

  run rg -n "pull_request|push:|behavioral-single-vm|checks.x86_64-linux.integration.behavioral_core_single_vm|bin/test.sh --lint|bin/test.sh unit" .github/workflows/factory.yml
  [ "$status" -eq 0 ]
}

@test "ci status helper script supports latest commit and logs modes" {
  run rg -n "caf-ci-status|--latest|--commit|--logs|gh run list|gh run view" cli/scripts/caf-ci-status
  [ "$status" -eq 0 ]
}

@test "ci workflow uploads diagnostics artifacts for failed jobs" {
  run rg -n "upload-artifact@v4|lint-and-eval-logs|unit-test-logs|behavioral-single-vm-logs|packaging-gate-logs" .github/workflows/factory.yml
  [ "$status" -eq 0 ]
}

@test "flaky test quarantine is tracked and enforceable in ci" {
  run test -f tests/flaky/quarantine.txt
  [ "$status" -eq 0 ]

  run rg -n "caf-test-quarantine|--strict|Flaky quarantine tracking" cli/scripts/caf-test-quarantine .github/workflows/factory.yml
  [ "$status" -eq 0 ]
}

@test "security audit exists and is enforced in ci" {
  run rg -n "caf-security-audit|Floating GitHub Action refs|StrictHostKeyChecking=no|flake.lock|devbox.lock" cli/scripts/caf-security-audit
  [ "$status" -eq 0 ]

  run rg -n "Security and supply-chain audit|caf-security-audit" .github/workflows/factory.yml
  [ "$status" -eq 0 ]
}

@test "performance audit script exists with core responsiveness thresholds" {
  run rg -n "caf-perf-audit|CAF_PERF_STATUS_MS|CAF_PERF_FLEET_MS|CAF_PERF_WORKSPACE_DRYRUN_MS|caf-fleet status|caf-workspace-run --dry-run" cli/scripts/caf-perf-audit
  [ "$status" -eq 0 ]
}

@test "reproducibility bootstrap and safe upgrade scripts exist" {
  run rg -n "caf-bootstrap-from-git|--dry-run|--force|install.sh --yes|Bootstrap complete" cli/scripts/caf-bootstrap-from-git
  [ "$status" -eq 0 ]

  run rg -n "caf-upgrade-safe|backups/upgrades|git pull --rebase|caf-system-rebuild|State backup captured" cli/scripts/caf-upgrade-safe
  [ "$status" -eq 0 ]

  run test -f docs/REPRODUCIBILITY.md
  [ "$status" -eq 0 ]
}

@test "core scripts support adjustable log verbosity levels" {
  run rg -n "CAFAYE_LOG_LEVEL|quiet\\|info\\|debug|level: \\$LOG_LEVEL" cli/scripts/caf-fleet cli/scripts/caf-sync cli/scripts/caf-system-rebuild
  [ "$status" -eq 0 ]
}

@test "distributed workflow and security model docs exist" {
  run test -f docs/DISTRIBUTED-WORKFLOW.md
  [ "$status" -eq 0 ]

  run test -f docs/SECURITY-MODEL.md
  [ "$status" -eq 0 ]

  run rg -n "Threat Assumptions|Trust Boundaries|Incident Response" docs/SECURITY-MODEL.md
  [ "$status" -eq 0 ]
}

@test "secret rotation runbook exists with validation workflow" {
  run test -f docs/SECRET-ROTATION.md
  [ "$status" -eq 0 ]

  run rg -n "Rotation Workflow|Validation Checklist|Rollback Plan" docs/SECRET-ROTATION.md
  [ "$status" -eq 0 ]
}
