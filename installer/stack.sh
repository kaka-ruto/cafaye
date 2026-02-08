#!/bin/bash
# Cafaye OS: Development Stack Configuration Helpers

# Preset configurations as simple JSON strings
PRESETS_rails='{
  "languages": {"ruby": true, "python": false, "nodejs": false, "rust": false, "go": false},
  "frameworks": {"rails": true, "django": false, "nextjs": false},
  "services": {"postgresql": true, "redis": false, "docker": true},
  "editors": {"neovim": true, "default": "neovim", "distributions": {"nvim": {"lazyvim": true}}}
}'

PRESETS_django='{
  "languages": {"ruby": false, "python": true, "nodejs": false, "rust": false, "go": false},
  "frameworks": {"rails": false, "django": true, "nextjs": false},
  "services": {"postgresql": true, "redis": false, "docker": true},
  "editors": {"neovim": true, "default": "neovim", "distributions": {"nvim": {"lazyvim": true}}}
}'

PRESETS_nextjs='{
  "languages": {"ruby": false, "python": false, "nodejs": true, "rust": false, "go": false},
  "frameworks": {"rails": false, "django": false, "nextjs": true},
  "services": {"postgresql": false, "redis": false, "docker": true},
  "editors": {"neovim": true, "default": "neovim", "distributions": {"nvim": {"lazyvim": true}}}
}'

PRESETS_go='{
  "languages": {"ruby": false, "python": false, "nodejs": false, "rust": false, "go": true},
  "frameworks": {},
  "services": {"postgresql": false, "redis": false, "docker": true},
  "editors": {"helix": true, "default": "helix"}
}'

PRESETS_rust='{
  "languages": {"ruby": false, "python": false, "nodejs": false, "rust": true, "go": false},
  "frameworks": {},
  "services": {"postgresql": false, "redis": false, "docker": true},
  "editors": {"helix": true, "default": "helix"}
}'

PRESETS_fullstack='{
  "languages": {"ruby": false, "python": true, "nodejs": true, "rust": false, "go": false},
  "frameworks": {"django": true, "nextjs": true},
  "services": {"postgresql": true, "redis": true, "docker": true},
  "editors": {"neovim": true, "default": "neovim", "distributions": {"nvim": {"lazyvim": true}}}
}'

# Show preset selection menu
show_presets() {
  echo "Choose a development preset:"
  echo ""
  
  local preset=$(gum choose --cursor "👉 " \
    "Ruby on Rails Developer" \
    "Python Django Developer" \
    "Node.js/React Developer" \
    "Go Backend Developer" \
    "Rust Systems Developer" \
    "Full-Stack Developer" \
    "Custom Configuration" \
    --header "Select your stack")
  
  case "$preset" in
    "Ruby on Rails Developer") echo "rails" ;;
    "Python Django Developer") echo "django" ;;
    "Node.js/React Developer") echo "nextjs" ;;
    "Go Backend Developer") echo "go" ;;
    "Rust Systems Developer") echo "rust" ;;
    "Full-Stack Developer") echo "fullstack" ;;
    *) echo "custom" ;;
  esac
}

# Get preset JSON
get_preset() {
  local preset=$1
  local varname="PRESETS_${preset}"
  eval "echo \"\${$varname}\""
}

# Editor configuration
configure_editors() {
  local editor=$(gum choose --cursor "👉 " \
    "Neovim (LazyVim)" \
    "Neovim (AstroNvim)" \
    "Neovim (NvChad)" \
    "Helix" \
    "VS Code Server" \
    --header "Code Editor")
  
  case "$editor" in
    "Neovim (LazyVim)")
      echo '{"neovim": true, "default": "neovim", "distributions": {"nvim": {"lazyvim": true, "astronvim": false, "nvchad": false, "lunarvim": false}}}'
      ;;
    "Neovim (AstroNvim)")
      echo '{"neovim": true, "default": "neovim", "distributions": {"nvim": {"lazyvim": false, "astronvim": true, "nvchad": false, "lunarvim": false}}}'
      ;;
    "Neovim (NvChad)")
      echo '{"neovim": true, "default": "neovim", "distributions": {"nvim": {"lazyvim": false, "astronvim": false, "nvchad": true, "lunarvim": false}}}'
      ;;
    "Helix")
      echo '{"helix": true, "default": "helix"}'
      ;;
    "VS Code Server")
      echo '{"vscode_server": true, "default": "vscode"}'
      ;;
    *)
      echo '{}'
      ;;
  esac
}

# Theme configuration
configure_theme() {
  local theme=$(gum choose --cursor "👉 " \
    "Catppuccin Mocha" \
    "Catppuccin Latte" \
    "Tokyo Night" \
    "Gruvbox" \
    "Nord" \
    --header "Terminal Theme")
  
  # Convert to lowercase with hyphens
  echo "$theme" | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
}

# Merge configuration objects
merge_json() {
  local base="$1"
  local override="$2"
  echo "$base $override" | jq -s '.[0] * .[1]' 2>/dev/null || echo "$override"
}
