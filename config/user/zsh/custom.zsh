# --- [ USER ALIASES ] ---

# Editors
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Git
alias gst='git status'
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gca="git commit --amend"
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Ruby & Rails
alias be="bundle exec"
alias bi="bundle install"
alias br="bin/rails"
alias brc="bin/rails console"
alias brm="bin/rails db:migrate"
alias brt="bin/rails test"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Tools
alias lg="lazygit"
alias ld="lazydocker"

# Kamal
alias kw="kamal app"
alias kp="kamal proxy"
alias ka="kamal accessory"
alias kdep="kamal deploy"
alias kwboot="kamal app boot"
alias kd="kamal details"
alias kwd="kamal app details"
alias kad="kamal accessory details"
alias kaboot="kamal accessory boot"
alias kareboot="kamal accessory reboot"
alias kpreboot="kamal proxy reboot"
alias karemove="kamal accessory remove"
alias kalogs="kamal accessory logs"
alias kplogs="kamal proxy logs"
alias kwlogs="kamal app logs -r web"
alias kexecapp="kamal app exec -r web --reuse -i bash"
alias kwrc="kamal app exec -r web --reuse -i 'bin/rails console'"
alias kae="kamal app exec"
alias kep="kamal env push"

# Rails convenience
alias bers="bundle exec rspec"
alias brr="bin/rails rspec"
alias brdm="bin/rails db:migrate"
alias brgm="bin/rails g migration"
alias brdr="bin/rails db:rollback"
alias brds="bin/rails db:seed"
alias tdl="tail -f log/development.log"
alias ttl="tail -f log/test.log"
alias groutes="bin/rails routes | fzf -e"

# Docker convenience
alias dk='docker'
alias dc='docker compose'
alias dcr='docker compose run'
alias dcb='docker compose build'
alias dcu='docker compose up'
alias dcd='docker compose down'

# Quality-of-life
alias week_number='date +%V'
alias path='echo -e ${PATH//:/\\n}'
alias reload_shell='exec ${SHELL} -l'

# Postgres defaults used in local workflows
export PGDATABASE="${PGDATABASE:-postgres}"
export PGUSER="${PGUSER:-postgres}"
export PGHOST="${PGHOST:-localhost}"
