# Cafaye Zsh Defaults
# ═══════════════════════════════════════════════════════════════════

# Note: Basic aliases (ls, grep, etc.) are already handled by the HM module
# This file is for extra shell logic/defaults.

# Ensure Cafaye helper scripts are available first.
export PATH="$HOME/.config/cafaye/bin:$PATH"
export PATH="$HOME/.config/cafaye/config/cafaye/bin:$PATH"

# Greet if interactive
if [[ $- == *i* ]]; then
  :
fi

# Auto-attach to the Cafaye tmux workspace for terminal-first workflows.
# Disable by setting: export CAFAYE_AUTO_TMUX=0
if [[ $- == *i* ]] && [[ -t 0 ]] && [[ -t 1 ]] && [[ -z "${TMUX:-}" ]] && [[ "${CAFAYE_AUTO_TMUX:-1}" == "1" ]]; then
  if command -v caf-workspace-init >/dev/null 2>&1; then
    exec caf-workspace-init --attach
  elif command -v tmux >/dev/null 2>&1; then
    exec tmux attach -t "${CAFAYE_TMUX_SESSION:-cafaye}" || exec tmux new -s "${CAFAYE_TMUX_SESSION:-cafaye}"
  fi
fi

# Show Cafaye status at shell startup unless explicitly disabled.
if [[ $- == *i* ]] && command -v caf-state-read >/dev/null 2>&1 && command -v caf-status >/dev/null 2>&1; then
  autostatus="$(caf-state-read core.autostatus 2>/dev/null || echo null)"
  if [[ "$autostatus" != "false" ]]; then
    caf-status
  fi
fi

# fzf key bindings if available
if command -v fzf >/dev/null 2>&1; then
  for fzf_bindings in \
    "/usr/share/fzf/key-bindings.zsh" \
    "${HOME}/.nix-profile/share/fzf/key-bindings.zsh" \
    "/etc/profiles/per-user/${USER}/share/fzf/key-bindings.zsh"; do
    if [[ -f "$fzf_bindings" ]]; then
      source "$fzf_bindings"
      break
    fi
  done
fi

# Basic completion for `caf`
if whence compdef >/dev/null 2>&1; then
  _cafaye_complete() {
    local -a cmds
    cmds=(
      'install:Install tools'
      'config:Configure Cafaye'
      'status:Show status'
      'project:Project sessions'
      'apply:Apply changes'
      'sync:Sync config'
      'fleet:Fleet operations'
      'backup:Backup status'
      'test:Run tests'
      'update:Update foundation'
    )
    _describe 'caf commands' cmds
  }
  compdef _cafaye_complete caf
fi

# Example function: extract many types of archives
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
