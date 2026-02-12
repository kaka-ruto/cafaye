# ~/.config/cafaye/config/user/zsh/custom.zsh
# ═══════════════════════════════════════════════════════════════════
# Your Zsh Customizations
# ═══════════════════════════════════════════════════════════════════
#
# This file is sourced by Cafaye's Zsh configuration.
# Add your aliases, functions, and shell customizations here.
#
# Documentation: https://zsh.sourceforge.io/Doc/
# ═══════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════
# ALIASES
# ═══════════════════════════════════════════════════════════════════

# Navigation
# alias ..='cd ..'
# alias ...='cd ../..'
# alias ....='cd ../../..'
# alias -- -='cd -'

# Listing
# alias ls='ls --color=auto'
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'

# Git shortcuts (but use lazygit for most operations!)
# alias g='git'
# alias gs='git status'
# alias ga='git add'
# alias gc='git commit'
# alias gp='git push'
# alias gl='git pull'
# alias gd='git diff'
# alias gco='git checkout'
# alias gb='git branch'

# Rails
# alias rs='rails server'
# alias rc='rails console'
# alias rg='rails generate'
# alias rdb='rails db:migrate'
# alias rdbt='rails db:test:prepare'

# Docker
# alias d='docker'
# alias dc='docker-compose'
# alias dps='docker ps'
# alias dcup='docker-compose up'
# alias dcdown='docker-compose down'

# Tmux
# alias t='tmux'
# alias ta='tmux attach'
# alias tn='tmux new-session'
# alias tls='tmux list-sessions'

# Cafaye shortcuts
# alias caf='caf'
# alias cfi='caf install'
# alias cfs='caf sync push'
# alias cfd='caf doctor'

# ═══════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

# Create a new directory and cd into it
# mkcd() {
#     mkdir -p "$1" && cd "$1"
# }

# Extract any archive
# extract() {
#     if [ -f $1 ]; then
#         case $1 in
#             *.tar.bz2)   tar xjf $1     ;;
#             *.tar.gz)    tar xzf $1     ;;
#             *.bz2)       bunzip2 $1     ;;
#             *.rar)       unrar e $1     ;;
#             *.gz)        gunzip $1      ;;
#             *.tar)       tar xf $1      ;;
#             *.tbz2)      tar xjf $1     ;;
#             *.tgz)       tar xzf $1     ;;
#             *.zip)       unzip $1       ;;
#             *.Z)         uncompress $1  ;;
#             *.7z)        7z x $1        ;;
#             *)           echo "'$1' cannot be extracted via extract()" ;;
#         esac
#     else
#         echo "'$1' is not a valid file"
#     fi
# }

# Fuzzy find and cd to directory
# fd() {
#     local dir
#     dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
#     cd "$dir"
# }

# Fuzzy find and open file in nvim
# fv() {
#     local file
#     file=$(find ${1:-.} -type f -not -path '*/\.*' 2> /dev/null | fzf +m) &&
#     nvim "$file"
# }

# ═══════════════════════════════════════════════════════════════════
# ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════════════════════════

# Add to PATH
# export PATH="$HOME/bin:$PATH"
# export PATH="$HOME/.local/bin:$PATH"

# Editor
# export EDITOR='nvim'
# export VISUAL='nvim'

# Language settings
# export LANG='en_US.UTF-8'
# export LC_ALL='en_US.UTF-8'

# Ripgrep config
# export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# FZF settings
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
# export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ═══════════════════════════════════════════════════════════════════
# KEYBINDINGS
# ═══════════════════════════════════════════════════════════════════

# Emacs-style keybindings (default in Zsh)
# bindkey -e

# Vim-style keybindings (if preferred)
# bindkey -v

# FZF keybindings
# bindkey '^r' fzf-history-widget
# bindkey '^t' fzf-file-widget
# bindkey '^[c' fzf-cd-widget

# ═══════════════════════════════════════════════════════════════════
# COMPLETION
# ═══════════════════════════════════════════════════════════════════

# Case-insensitive completion
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Fuzzy completion
# zstyle ':completion:*' completer _expand_alias _complete _approximate
# zstyle ':completion:*' menu select

# ═══════════════════════════════════════════════════════════════════
# YOUR CUSTOMIZATIONS BELOW
# ═══════════════════════════════════════════════════════════════════

