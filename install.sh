#!/usr/bin/env bash
# Cafaye Foundation Installer
# Plan -> Confirm -> Execute

set -e

# --- Automation ---
NON_INTERACTIVE=false
if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]]; then
    NON_INTERACTIVE=true
    GIT_NAME="Cafaye Test"
    GIT_EMAIL="test@cafaye.com"
    BACKUP_TYPE="Local only"
    PUSH_STRATEGY="Push manually"
    EDITOR_CHOICE="Neovim"
    NVIM_DISTRO="LazyVim (recommended)"
    THEME_CHOICE="Catppuccin Mocha"
    SET_TAILSCALE="no"
    NETWORK_MODE="tailscale"
    IS_VPS="no"
    IMPORT_SSH="no"
    SSH_PROVIDER="skip"
    SSH_USER=""
    SSH_IMPORT_MODE="Skip (configure later with: caf config ssh)"
    SSH_KEY_PATH=""
    SSH_KEY_VALUE=""
    AUTO_SHUTDOWN="yes"
    REPO_URL=""
    TAILSCALE_KEY=""
fi
set -e
set -o pipefail

# --- Logging Setup (Deferred to Execution) ---
LOG_DIR="$HOME/.config/cafaye/logs"
mkdir -p "$LOG_DIR"
# We'll redirect output only when the execution phase starts to keep GUM interactive

# --- Signal Handling ---
cleanup() {
    echo -e "\n\n👋 Installation cancelled. See you later!"
    exit 3
}
trap cleanup SIGINT SIGTERM

# --- Idempotency ---
check_idempotency() {
    if [[ -d "$HOME/.config/cafaye" ]] && [[ -f "$HOME/.config/cafaye/environment.json" ]]; then
        echo "✨ Existing Cafaye installation detected at ~/.config/cafaye"
        if [[ "$NON_INTERACTIVE" == "true" ]]; then
            echo "Non-interactive mode: updating existing installation..."
            return
        fi

        CHOICE=$(gum choose "Update existing foundation" "Reconfigure (run installer again)" "Clean Install (Wipe & Start fresh)" "Exit")
        case "$CHOICE" in
            "Update existing foundation")
                echo "🚀 Updating..."
                # Run rebuild
                export PATH="$HOME/.nix-profile/bin:$PATH"
                bash "$HOME/.config/cafaye/cli/scripts/caf-system-rebuild"
                echo "✅ Update complete!"
                exit 0
                ;;
            "Reconfigure"*)
                echo "🛠️  Starting reconfiguration..."
                ;;
            "Clean Install"*)
                echo "⚠️  Wiping existing installation..."
                TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                mv "$HOME/.config/cafaye" "$HOME/.config/cafaye.bak.$TIMESTAMP"
                echo "📁 Existing config backed up to ~/.config/cafaye.bak.$TIMESTAMP"
                ;;
            "Exit")
                exit 0
                ;;
        esac
    fi
}

# --- Visual Elements (Cafaye Mauve Theme) ---
export GUM_INPUT_CURSOR_FOREGROUND="#cba6f7"
export GUM_INPUT_PROMPT_FOREGROUND="#cba6f7"
export GUM_INPUT_PLACEHOLDER_FOREGROUND="#585b70"
export GUM_INPUT_WIDTH=80
export GUM_INPUT_PROMPT="> "
export GUM_CHOOSE_CURSOR_FOREGROUND="#cba6f7"
export GUM_CHOOSE_HEADER_FOREGROUND="#cba6f7"
export GUM_CHOOSE_SELECTED_FOREGROUND="#cba6f7"
export GUM_CHOOSE_CURSOR="❯ "
export GUM_CONFIRM_SELECTED_BACKGROUND="#cba6f7"
export GUM_CONFIRM_SELECTED_FOREGROUND="#1e1e2e"
export GUM_CONFIRM_UNSELECTED_BACKGROUND="#313244"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="#cdd6f4"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[38;2;203;166;247m' # Mauve TrueColor
NC='\033[0m'
CYAN='\033[0;36m'

# Defaults to avoid unbound variables in optional branches
REPO_URL="${REPO_URL:-}"
TAILSCALE_KEY="${TAILSCALE_KEY:-}"
SET_TAILSCALE="${SET_TAILSCALE:-no}"
NETWORK_MODE="${NETWORK_MODE:-tailscale}"
IS_VPS="${IS_VPS:-no}"
IMPORT_SSH="${IMPORT_SSH:-no}"
SSH_PROVIDER="${SSH_PROVIDER:-skip}"
SSH_USER="${SSH_USER:-}"
SSH_IMPORT_MODE="${SSH_IMPORT_MODE:-Skip (configure later with: caf config ssh)}"
SSH_KEY_PATH="${SSH_KEY_PATH:-}"
SSH_KEY_VALUE="${SSH_KEY_VALUE:-}"
AUTO_SHUTDOWN="${AUTO_SHUTDOWN:-yes}"

show_logo() {
    if [[ "$NON_INTERACTIVE" != "true" ]] && [[ -n "$TERM" ]]; then
        clear
    fi
    echo -e "${PURPLE}"
    cat << "EOF"
    ☕ Cafaye
    -----------------------------------------------------------------------
    The distributed development infrastructure for humans and AI
    -----------------------------------------------------------------------
EOF
    echo -e "${NC}"
}
detect_system() {
    echo "🔍 Detecting system..."
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    case "$OS" in
        Darwin) OS_NAME="macOS" ;;
        Linux)  OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2) ;;
        *)      OS_NAME="Unknown" ;;
    esac

    echo "✅ $OS_NAME ($ARCH)"
    
    # Check for Nix
    if command -v nix &> /dev/null; then
        echo "✅ Nix is already installed"
    else
        echo "ℹ️  Nix will be installed"
    fi

    # Check for disk space (need 500MB+)
    if [[ "$OS" == "Darwin" ]]; then
        FREE_SPACE_MB=$(df -m / | awk 'NR==2 {print $4}')
    else
        FREE_SPACE_MB=$(df -m / | awk 'NR==2 {print $4}' | tr -d 'M')
    fi

    if [[ $FREE_SPACE_MB -lt 500 ]]; then
        echo "❌ Not enough disk space (need 500MB+, found ${FREE_SPACE_MB}MB)"
        exit 2
    fi
    echo "✅ Disk space available"
}

# --- Dependencies ---
ensure_dependencies() {
    if ! command -v gum &> /dev/null; then
        echo "Installing bootstrap tools..."
        # Simplified gum install for Mac/Linux
        if [[ "$(uname -s)" == "Darwin" ]]; then
            if ! command -v brew &> /dev/null; then
                 # Fallback to direct download if no brew
                 ARCH=$(uname -m)
                 [[ "$ARCH" == "x86_64" ]] && GUM_ARCH="x86_64" || GUM_ARCH="arm64"
                 URL="https://github.com/charmbracelet/gum/releases/download/v0.14.3/gum_0.14.3_Darwin_${GUM_ARCH}.tar.gz"
                 curl -fL "$URL" -o gum.tar.gz
                 tar xzf gum.tar.gz
                 mv gum_0.14.3_Darwin_${GUM_ARCH}/gum /usr/local/bin/gum || cp gum_0.14.3_Darwin_${GUM_ARCH}/gum /tmp/gum
                 export PATH="/tmp:$PATH"
            else
                 brew install gum jq
            fi
        else
            # Linux (simplified)
            apt-get update && apt-get install -y gum jq git curl || true
        fi
    fi
}

# --- Phase 1: Plan ---
plan_phase() {
    [[ "$NON_INTERACTIVE" == "true" ]] && return
    show_logo
    echo "Welcome to Cafaye! Let's set up your foundation."
    echo ""

    # 1. Git Identity
    GIT_NAME=$(git config --get user.name || echo "")
    GIT_EMAIL=$(git config --get user.email || echo "")

    if [[ -z "$GIT_NAME" ]]; then
        GIT_NAME=$(gum input --placeholder "What is your name?" --header "Git Identity: Name")
    fi
    if [[ -z "$GIT_EMAIL" ]]; then
        GIT_EMAIL=$(gum input --placeholder "What is your email?" --header "Git Identity: Email")
    fi

    # 2. Backup Strategy
    BACKUP_TYPE=$(gum choose --header "Where would you like to back up your environment?" "GitHub (recommended)" "GitLab" "Local only" "Skip for now")
    
    if [[ "$BACKUP_TYPE" == "GitHub (recommended)" ]] || [[ "$BACKUP_TYPE" == "GitLab" ]]; then
        while true; do
            # Use /dev/tty to ensure gum interacts directly with the user
            REPO_URL=$(gum input --placeholder "https://github.com/user/cafaye" \
                                --header "$BACKUP_TYPE Repository URL (Enter full https:// URL)" \
                                < /dev/tty)
            
            if [[ "$REPO_URL" == https://* ]]; then
                break
            else
                echo -e "${RED}⚠️  Error: Please provide a full URL starting with https://${NC}" >&2
                sleep 1
            fi
        done
    fi

    PUSH_STRATEGY=$(gum choose --header "Push Strategy" "Push immediately" "Push daily (recommended)" "Push manually")

    # 3. Editor selection
    EDITOR_CHOICE=$(gum choose --header "Choose Your Editor" "Neovim" "Helix" "VS Code Server" "Skip")
    
    if [[ "$EDITOR_CHOICE" == "Neovim" ]]; then
        NVIM_DISTRO=$(gum choose --header "Choose Neovim Distribution" "LazyVim (recommended)" "AstroNvim" "NvChad" "None (Base Neovim)")
    fi

    # 4. Theme selection
    THEME_CHOICE=$(gum choose --header "Choose Your Theme" "Catppuccin Mocha" "Tokyo Night" "Gruvbox")

    # 5. Secure Access (Tailscale) - REFINED ONBOARDING
    show_logo
    echo -e "${BLUE}🔐 Secure Remote Access (Tailscale)${NC}"
    echo "Tailscale creates a secure, private network between all your Cafaye nodes."
    echo "It allows you to sync your fleet and access your data from anywhere"
    echo "without opening any firewall ports or managing complex VPNs."
    echo ""
    echo -e "💡 ${GREEN}Highly Recommended${NC} if you plan to use a VPS or multiple machines."
    echo -e "   ${CYAN}Notice:${NC} Tailscale is free for personal use and we handle the installation."
    echo "   You don't need to download any apps now."
    echo ""

    TS_ACTION=$(gum choose \
        "Set up Tailscale now (Recommended)" \
        "Yes, help me create an account" \
        "Remind me later" \
        "No, I'll use direct SSH" \
        "What is Tailscale?")
    
    if [[ "$TS_ACTION" == "Yes, help me create an account" ]]; then
        if command -v open >/dev/null 2>&1; then
            open "https://login.tailscale.com/start" >/dev/null 2>&1 || true
        elif command -v xdg-open >/dev/null 2>&1; then
            xdg-open "https://login.tailscale.com/start" >/dev/null 2>&1 || true
        fi
        TS_ACTION="Set up Tailscale now (Recommended)"
    fi

    if [[ "$TS_ACTION" == "What is Tailscale?" ]]; then
        gum style --border normal --margin "1 2" --padding "1 2" --foreground 212 \
            "Tailscale is a zero-config VPN. It creates a 'Tailnet' where all your" \
            "devices get a private 100.x.x.x IP address. It's built on WireGuard," \
            "is end-to-end encrypted, and works through any NAT or Firewall."
        TS_ACTION=$(gum choose "Set up Tailscale now" "Remind me later" "No, I'll use direct SSH")
    fi

    SET_TAILSCALE="no"
    NETWORK_MODE="tailscale"
    if [[ "$TS_ACTION" == "No, I'll use direct SSH" ]]; then
        NETWORK_MODE="direct-ssh"
        SET_TAILSCALE="no"
    fi

    if [[ "$TS_ACTION" == *"Set up Tailscale"* ]]; then
        HAS_ACCOUNT=$(gum confirm "Do you already have a Tailscale account?" --affirmative "Yes, let's connect" --negative "No, not yet" && echo "yes" || echo "no")
        
        if [[ "$HAS_ACCOUNT" == "no" ]]; then
            echo -e "\n${BLUE}Let's get you set up (it's free for personal use):${NC}"
            echo "1. Go to: https://login.tailscale.com/start"
            echo "2. Create your account using Google, GitHub, or Microsoft."
            echo "3. Go to Settings -> Keys (you can skip the 'Get Started' intro)."
            echo "4. Generate an 'Auth Key' (Reusable is recommended for fleet use)."
            echo ""
            
            READY=$(gum choose "I've generated my key" "Skip Tailscale for now")
            if [[ "$READY" == "Skip Tailscale for now" ]]; then
                SET_TAILSCALE="no"
            else
                SET_TAILSCALE="yes"
            fi
        else
            SET_TAILSCALE="yes"
        fi

        if [[ "$SET_TAILSCALE" == "yes" ]]; then
            echo -e "\n${CYAN}🛡️  Security Note:${NC} Your key is used for one-time authentication and"
            echo "stored locally in your encrypted fleet metadata. It is never shared."
            echo ""
            TAILSCALE_KEY=$(gum input --password --placeholder "Paste your Tailscale Auth Key (tskey-auth-...)" --header "Tailscale Connectivity")
            if [[ -z "$TAILSCALE_KEY" ]]; then
                echo "⚠️  No key provided, skipping Tailscale initialization."
                SET_TAILSCALE="no"
            fi
        fi
    fi

    # 6. VPS-specific options (Prompt if Linux and looks like cloud, or always on Linux)
    IS_VPS="no"
    if [[ "$OS" == "Linux" ]]; then
        IS_VPS=$(gum confirm "Is this a VPS/Remote Server? (Enables SSH key import & auto-shutdown)" && echo "yes" || echo "no")
    fi

    if [[ "$IS_VPS" == "yes" ]]; then
        SSH_IMPORT_MODE=$(gum choose \
            "From SSH agent" \
            "From file: ~/.ssh/id_ed25519.pub" \
            "Paste manually" \
            "Skip (configure later with: caf config ssh)")

        IMPORT_SSH="no"
        SSH_PROVIDER="none"
        SSH_USER=""
        SSH_KEY_PATH=""
        SSH_KEY_VALUE=""
        case "$SSH_IMPORT_MODE" in
            "From SSH agent")
                IMPORT_SSH="yes"
                SSH_PROVIDER="agent"
                ;;
            "From file: ~/.ssh/id_ed25519.pub")
                IMPORT_SSH="yes"
                SSH_PROVIDER="file"
                SSH_KEY_PATH="$HOME/.ssh/id_ed25519.pub"
                [[ -f "$SSH_KEY_PATH" ]] && SSH_KEY_VALUE="$(cat "$SSH_KEY_PATH")"
                ;;
            "Paste manually")
                IMPORT_SSH="yes"
                SSH_PROVIDER="manual"
                SSH_KEY_VALUE=$(gum input --placeholder "ssh-ed25519 AAAA... user@host" --header "Paste public SSH key")
                ;;
            *)
                IMPORT_SSH="no"
                SSH_PROVIDER="skip"
                ;;
        esac
        
        AUTO_SHUTDOWN=$(gum confirm "Enable auto-shutdown after 1 hour of inactivity?" && echo "yes" || echo "no")
    fi
}

# --- Phase 2: Confirm ---
confirm_phase() {
    [[ "$NON_INTERACTIVE" == "true" ]] && return
    show_logo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📋 Installation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "⚙️  Foundation: Nix + Home Manager"
    echo "📝 Git Identity: $GIT_NAME <$GIT_EMAIL>"
    echo "💾 Backup: $BACKUP_TYPE"
    [[ -n "$REPO_URL" ]] && echo "   Repo: $REPO_URL"
    echo "🔄 Push: $PUSH_STRATEGY"
    echo "🎨 Theme: $THEME_CHOICE"
    echo "📝 Editor: $EDITOR_CHOICE"
    [[ -n "$NVIM_DISTRO" ]] && echo "   Distro: $NVIM_DISTRO"
    echo "🔐 Tailscale: $SET_TAILSCALE"
    [[ -n "${NETWORK_MODE:-}" ]] && echo "   Network mode: ${NETWORK_MODE}"
    if [[ "$IS_VPS" == "yes" ]]; then
        echo "🌐 VPS Mode: Enabled"
        echo "   Import SSH: $IMPORT_SSH ($SSH_PROVIDER: $SSH_USER)"
        echo "   Auto-shutdown: $AUTO_SHUTDOWN"
    fi
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    gum confirm "Ready to fully install Cafaye?" || exit 3
}

# --- Phase 3: Execute ---
execute_phase() {
    # Initialize logging here to avoid breaking interactive prompts above
    exec 3>&1 4>&2
    exec 1> >(tee -a "$LOG_DIR/install.log" >&3) 2> >(tee -a "$LOG_DIR/install.log" >&4)

    echo -e "${BLUE}🚀 Starting installation...${NC}"
    
    # 1. Prepare directory
    CAFAYE_DIR="$HOME/.config/cafaye"
    mkdir -p "$CAFAYE_DIR"
    
    # 2. Populate ~/.config/cafaye
    echo "📦 Initializing directory structure..."
    # If we are in the repo already, sync files excluding .git, .devbox, and state files
    if [[ -f "./flake.nix" ]]; then
        # Use find/cp to avoid permission issues and preserve state
        # Exclude result (Nix symlink) and .cache to prevent permission errors
        find . -maxdepth 1 ! -name ".git" ! -name ".devbox" ! -name ".cache" ! -name "result" ! -name "environment.json" ! -name "local-user.nix" ! -name "." -exec cp -r {} "$CAFAYE_DIR/" \;
    else
        echo "Cloning Cafaye repository..."
        git clone --depth 1 https://github.com/cafaye/cafaye "$CAFAYE_DIR"
        rm -rf "$CAFAYE_DIR/.git" # Start with a fresh env repo
    fi

    # Ensure scripts are executable
    chmod +x "$CAFAYE_DIR/cli/scripts/"* 2>/dev/null || true

    cd "$CAFAYE_DIR"

    # 3. Save state
    if [[ ! -f "$CAFAYE_DIR/environment.json" ]]; then
        echo "📝 Saving environment choices..."
        cat > "$CAFAYE_DIR/environment.json" <<EOF
{
  "interface": {
    "theme": "$(echo "$THEME_CHOICE" | tr '[:upper:]' '[:lower:]')",
    "terminal": {
      "shell": "zsh"
    }
  },
  "editors": {
    "default": "$(echo "$EDITOR_CHOICE" | tr '[:upper:]' '[:lower:]')",
    "neovim": $([[ "$EDITOR_CHOICE" == "Neovim" ]] && echo true || echo false),
    "distributions": {
      "nvim": {
        "lazyvim": $([[ "$NVIM_DISTRO" == "LazyVim (recommended)" ]] && echo true || echo false),
        "astronvim": $([[ "$NVIM_DISTRO" == "AstroNvim" ]] && echo true || echo false),
        "nvchad": $([[ "$NVIM_DISTRO" == "NvChad" ]] && echo true || echo false)
      }
    }
  },
  "languages": {},
  "frameworks": {},
  "services": {},
  "ai": {}
}
EOF
    fi

    if [[ ! -f "$CAFAYE_DIR/settings.json" ]]; then
        echo "📝 Saving tool settings..."
        cat > "$CAFAYE_DIR/settings.json" <<EOF
{
    "core": {
      "vps": $([[ "$IS_VPS" == "yes" ]] && echo true || echo false),
      "auto_shutdown": $([[ "$AUTO_SHUTDOWN" == "yes" ]] && echo true || echo false),
      "network_mode": "${NETWORK_MODE:-tailscale}",
      "tailscale": {
        "enabled": $([[ "$SET_TAILSCALE" == "yes" ]] && echo true || echo false),
        "key": "$TAILSCALE_KEY"
      },
      "ssh": {
        "import": $([[ "$IMPORT_SSH" == "yes" ]] && echo true || echo false),
        "provider": "$(echo "$SSH_PROVIDER" | tr '[:upper:]' '[:lower:]')",
        "username": "$SSH_USER",
        "mode": "${SSH_IMPORT_MODE:-skip}",
        "path": "${SSH_KEY_PATH:-}",
        "public_key": "${SSH_KEY_VALUE:-}"
      }
  },
  "git": {
    "name": "$GIT_NAME",
    "email": "$GIT_EMAIL"
  },
  "backup": {
    "type": "$BACKUP_TYPE",
    "url": "$REPO_URL",
    "strategy": "$PUSH_STRATEGY"
  }
}
EOF
    fi

    # 4. Generate local-user.nix
    if [[ ! -f "$CAFAYE_DIR/local-user.nix" ]]; then
        echo "👤 Configuring user settings..."
        cat > "$CAFAYE_DIR/local-user.nix" <<EOF
{ ... }: {
  home.username = "$(whoami)";
  home.homeDirectory = "$HOME";
  home.stateVersion = "24.11";
}
EOF
    fi

    # 5. Install Nix if needed
    if ! command -v nix &> /dev/null; then
        echo "❄️  Installing Nix package manager..."
        curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
        if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
    fi

    # Ensure flakes are enabled
    echo "⚙️  Enabling Nix flakes..."
    mkdir -p "$HOME/.config/nix"
    if [[ ! -f "$HOME/.config/nix/nix.conf" || ! $(grep "experimental-features" "$HOME/.config/nix/nix.conf") ]]; then
        echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
    fi

    # 6. Initialize Git (Required for Flakes to see files)
    if [[ ! -d "$CAFAYE_DIR/.git" ]]; then
        echo "💾 Initializing backup repository..."
        cd "$CAFAYE_DIR"
        git init
        git config user.name "$GIT_NAME"
        git config user.email "$GIT_EMAIL"
        
        if [[ -n "$REPO_URL" ]]; then
            git remote add origin "$REPO_URL"
            echo "✅ Connected to origin ($REPO_URL)"
        fi
        
        # Add upstream for future updates
        git remote add upstream "https://github.com/cafaye/cafaye.git"
        echo "✅ Connected to upstream (https://github.com/cafaye/cafaye.git)"
        
        git add .
        git commit -m "Initial Cafaye environment setup"
    fi

    # Pre-emptively backup files that cause HM activation to fail
    echo "🧹 Handling existing configuration files..."
    for f in ".zshrc" ".zshenv" ".config/btop/btop.conf"; do
        if [[ -e "$HOME/$f" ]] || [[ -L "$HOME/$f" ]]; then
            # If it's already a symlink pointing to our store, we could skip it, 
            # but moving it is safer for a clean install.
            echo "   Backing up $f to $f.backup"
            mv "$HOME/$f" "$HOME/$f.backup"
        fi
    done

    # Pre-emptively remove conflicting profile packages
    if command -v nix &> /dev/null; then
        echo "🔍 Checking for conflicting Nix packages..."
        for pkg in "sops" "ssh-to-age"; do
            if nix profile list | grep -q "legacyPackages.*$pkg"; then
                echo "   Removing conflicting package from profile: $pkg"
                nix profile move "$pkg" 2>/dev/null || nix profile remove "$pkg" || true
            fi
        done
    fi

    # 7. Apply Home Manager configuration
    echo "🏗️  Building your environment (this may take a minute)..."
    cd "$CAFAYE_DIR"
    git add -A || true # Ensure Nix sees new files
    export NIX_CONFIG="experimental-features = nix-command flakes"
    SYSTEM_ARCH=$(uname -m)
    [[ "$SYSTEM_ARCH" == "arm64" ]] && SYSTEM_ARCH="aarch64"
    SYSTEM_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    [[ "$SYSTEM_OS" == "darwin" ]] && OS_SUFFIX="darwin" || OS_SUFFIX="linux"
    FLAKE_CONFIG="${SYSTEM_ARCH}-${OS_SUFFIX}"

    # Use nix run instead of assuming home-manager is in path
    nix run --extra-experimental-features "nix-command flakes" nixpkgs#home-manager -- switch --flake "$CAFAYE_DIR#$FLAKE_CONFIG" -b backup --show-trace

    # 8. Tailscale Activation (Seamless setup)
    if [[ "$SET_TAILSCALE" == "yes" ]]; then
        echo -e "\n${BLUE}🔐 Finalizing Tailscale Setup...${NC}"
        
        # Install Tailscale if not present
        if ! command -v tailscale &> /dev/null; then
            echo "Installing Tailscale..."
            if [[ "$OS" == "Darwin" ]]; then
                if command -v brew &> /dev/null; then
                    brew install tailscale
                else
                    echo "⚠️  Homebrew not found. Please install Tailscale for macOS manually: https://tailscale.com/download/mac"
                fi
            else
                # Linux: Use the official install script
                curl -fsSL https://tailscale.com/install.sh | sh
            fi
        fi

        # Authenticate if key is provided
        if [[ -n "$TAILSCALE_KEY" ]]; then
            echo "Authenticating with Tailscale..."
            # On Linux, tailscaled might need to be started first if it was just installed
            if [[ "$OS" == "Linux" ]]; then
                systemctl enable --now tailscaled || service tailscaled start || true
            fi
            
            # Run 'up' with the key
            # We use sudo for Linux to ensure it has permissions to create the tunnel
            if [[ "$OS" == "Linux" ]]; then
                sudo tailscale up --authkey "$TAILSCALE_KEY" --hostname "cafaye-$(whoami)-$(hostname)"
            else
                # macOS (CLI version)
                tailscale up --authkey "$TAILSCALE_KEY" --hostname "cafaye-$(whoami)-$(hostname)"
            fi
            echo "✅ Tailscale is connected!"
        fi
    fi

    show_success
}

show_success() {
    show_logo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🎉  SUCCESS! Cafaye is installed!"
    echo ""
    echo "    Your distributed development infrastructure is ready."
    echo ""
    echo "    ☕ ☕ ☕"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🎯  Quick Start:"
    echo "    Start terminal:      ghostty (or tmux)"
    echo "    Start workspace:     caf-workspace-init --attach"
    echo "    Open editor:         nvim"
    echo "    Main menu:           caf"
    echo ""
    echo "🛠️   Add Your Tools:"
    echo "    Install Ruby:        caf install ruby"
    echo "    Install AI tools:    caf install claude-code"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

auto_launch_workspace() {
    # Only auto-launch on interactive local GUI sessions.
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        return
    fi

    if [[ "$OS" == "Darwin" ]]; then
        if command -v open >/dev/null 2>&1; then
            open -a Ghostty >/dev/null 2>&1 || true
        fi
    else
        if [[ -n "${DISPLAY:-}" ]] && command -v ghostty >/dev/null 2>&1; then
            (ghostty -e bash -lc 'caf-workspace-init --attach' >/dev/null 2>&1 &) || true
        fi
    fi
}

safe_symlink() {
    local target="$1"
    local link_path="$2"

    mkdir -p "$(dirname "$link_path")"
    if [[ -e "$link_path" || -L "$link_path" ]]; then
        if [[ -L "$link_path" ]] && [[ "$(readlink "$link_path")" == "$target" ]]; then
            return 0
        fi
        local backup="${link_path}.cafaye-backup-$(date +%Y%m%d%H%M%S)"
        echo "   Backing up existing $(basename "$link_path") to $backup"
        mv "$link_path" "$backup"
    fi
    ln -s "$target" "$link_path"
}

create_standard_symlinks() {
    echo "🔗 Creating standard config symlinks..."
    safe_symlink "$HOME/.config/cafaye/config/cafaye/tmux" "$HOME/.config/tmux"
    safe_symlink "$HOME/.config/cafaye/config/cafaye/ghostty" "$HOME/.config/ghostty"
    safe_symlink "$HOME/.config/cafaye/config/cafaye/zsh/.zshrc" "$HOME/.zshrc"
}

# --- Main Flow Start ---
show_logo
detect_system
check_idempotency

while true; do
    plan_phase
    confirm_phase && break
done

execute_phase
create_standard_symlinks
auto_launch_workspace
