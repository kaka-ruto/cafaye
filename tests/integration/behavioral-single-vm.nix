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
      ];
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")

      machine.succeed("cp -r ${repoSrc} /tmp/cafaye")
      machine.succeed("chmod -R u+w /tmp/cafaye")

      # Fast static/runtime sanity checks in one VM.
      machine.succeed("cd /tmp/cafaye && bash bin/syntax-check.sh")
      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-version >/tmp/caf-version.out")
      machine.succeed("test -s /tmp/caf-version.out")

      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-status >/tmp/caf-status.out")
      machine.succeed("grep -q 'Cafaye Status' /tmp/caf-status.out")

      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-search status >/tmp/caf-search.out")
      machine.succeed("grep -q 'Cafaye Status' /tmp/caf-search.out")

      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-fleet status >/tmp/caf-fleet.out || true")
      machine.succeed("test -s /tmp/caf-fleet.out")

      machine.succeed("cd /tmp/cafaye && bash cli/scripts/caf-workspace-run --dry-run >/tmp/caf-workspace.out || true")
      machine.succeed("test -s /tmp/caf-workspace.out")

      machine.succeed("tmux -V >/tmp/tmux-version.out")
      machine.succeed("grep -q 'tmux' /tmp/tmux-version.out")
    '';
  }
else
  pkgs.runCommand "cafaye-behavioral-single-vm-skip-${pkgs.stdenv.hostPlatform.system}" { } ''
    mkdir -p "$out"
  ''
