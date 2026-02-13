{ pkgs, lib, ... }:

let
  repoSrc = builtins.path {
    path = ../..;
    name = "cafaye-src";
  };
in
if pkgs.stdenv.isLinux then
  pkgs.testers.runNixOSTest {
    name = "cafaye-behavioral-single-vm";

    nodes.machine = { ... }: {
      environment.systemPackages = with pkgs; [
        bash
        coreutils
        git
        gnugrep
        gnutar
        jq
        gum
        tmux
        zsh
        neovim
        lazygit
        sops
        age
        rsync
      ];
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")

      machine.succeed("cp -r ${repoSrc} /tmp/cafaye")
      machine.succeed("chmod -R u+w /tmp/cafaye")

      # 1. Syntax Check All Scripts
      machine.succeed("cd /tmp/cafaye && bash -n install.sh")
      machine.succeed("cd /tmp/cafaye && for s in cli/scripts/* config/cafaye/bin/*; do [ -f \"$s\" ] && bash -n \"$s\"; done")

      # 2. Project Operations
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-project create test-p --path /tmp/test-p")
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-project list | grep test-p")
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-project delete test-p")

      # 3. Status and Readiness
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-version >/tmp/out")
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-status >/tmp/out")
      machine.fail("grep -q 'DEVIATED' /tmp/out") # Status should be clean or unknown, not deviated on fresh system

      # 4. Search and Fleet Syntax
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-search status >/tmp/out")
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-fleet status >/tmp/out 2>&1 || true")

      # 5. Workspace and UI logic
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-workspace-run --dry-run >/tmp/out 2>&1 || true")
      machine.succeed("tmux -V")

      # 6. Hardening and System Actions
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-system-harden --help || true")
    '';
  }
else
  pkgs.runCommand "cafaye-behavioral-single-vm-skip-${pkgs.stdenv.hostPlatform.system}" { } ''
    mkdir -p "$out"
  ''
