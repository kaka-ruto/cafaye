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

# Search interface used by leader/shortcut workflows.
if ! command -v caf-search >/dev/null 2>&1; then
  caf-search() { caf install; }
fi

# Leader key/shortcut system (works locally and over SSH).
# Defaults:
# - leader key: Space
# - leader timeout: 500ms
# - double-tap open menu window: 300ms
if [[ $- == *i* ]] && [[ -t 0 ]] && [[ -t 1 ]] && whence zle >/dev/null 2>&1; then
  export CAFAYE_LEADER_KEY="${CAFAYE_LEADER_KEY:-space}"      # space|comma|backslash|escape
  export CAFAYE_LEADER_TIMEOUT_MS="${CAFAYE_LEADER_TIMEOUT_MS:-500}"
  export CAFAYE_DOUBLE_TAP_MS="${CAFAYE_DOUBLE_TAP_MS:-300}"

  _cafaye_leader_char=" "
  _cafaye_leader_bindkey=" "
  case "$CAFAYE_LEADER_KEY" in
    comma) _cafaye_leader_char=","; _cafaye_leader_bindkey="," ;;
    backslash) _cafaye_leader_char="\\"; _cafaye_leader_bindkey="\\" ;;
    escape) _cafaye_leader_char=$'\e'; _cafaye_leader_bindkey=$'\e' ;;
    *) _cafaye_leader_char=" "; _cafaye_leader_bindkey=" " ;;
  esac

  _cafaye_run_command() {
    local cmd="$1"
    BUFFER="$cmd"
    zle accept-line
  }

  _cafaye_leader_widget() {
    local timeout_sec
    local next
    local dt_ms
    local now_ms

    now_ms="$(($(date +%s%3N 2>/dev/null || echo 0)))"
    dt_ms=999999
    if [[ -n "${CAFAYE_LAST_LEADER_TS_MS:-}" ]]; then
      dt_ms=$(( now_ms - CAFAYE_LAST_LEADER_TS_MS ))
    fi
    CAFAYE_LAST_LEADER_TS_MS="$now_ms"

    # Double-tap leader opens the main menu quickly.
    if [[ "$dt_ms" -le "${CAFAYE_DOUBLE_TAP_MS}" ]]; then
      _cafaye_run_command "caf"
      return
    fi

    timeout_sec="$(awk "BEGIN { printf \"%.3f\", ${CAFAYE_LEADER_TIMEOUT_MS}/1000 }")"
    CAFAYE_LEADER_ACTIVE=1
    RPS1="[LEADER]"
    zle reset-prompt
    zle -M "[LEADER] s:search r:rebuild d:status m:menu .:sessions"

    if read -r -s -k 1 -t "$timeout_sec" next; then
      case "$next" in
        s|S) _cafaye_run_command "caf-search" ;;
        r|R) _cafaye_run_command "caf apply" ;;
        d|D) _cafaye_run_command "caf status" ;;
        m|M) _cafaye_run_command "caf" ;;
        .) _cafaye_run_command "caf fleet switch" ;;
        h|H) _cafaye_run_command "caf --help" ;;
        "$_cafaye_leader_char") _cafaye_run_command "caf" ;;
        *) LBUFFER+="${_cafaye_leader_char}${next}" ;;
      esac
    else
      LBUFFER+="${_cafaye_leader_char}"
    fi

    CAFAYE_LEADER_ACTIVE=0
    RPS1=""
    zle reset-prompt
  }
  zle -N _cafaye_leader_widget

  _cafaye_menu_widget() { _cafaye_run_command "caf"; }
  _cafaye_search_widget() { _cafaye_run_command "caf-search"; }
  _cafaye_rebuild_widget() { _cafaye_run_command "caf apply"; }
  _cafaye_status_widget() { _cafaye_run_command "caf status"; }
  zle -N _cafaye_menu_widget
  zle -N _cafaye_search_widget
  zle -N _cafaye_rebuild_widget
  zle -N _cafaye_status_widget

  # Space leader and Alt shortcuts for power users.
  bindkey "$_cafaye_leader_bindkey" _cafaye_leader_widget
  bindkey '\em' _cafaye_menu_widget
  bindkey '\ec' _cafaye_menu_widget
  bindkey '\es' _cafaye_search_widget
  bindkey '\er' _cafaye_rebuild_widget
  bindkey '\ed' _cafaye_status_widget
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
