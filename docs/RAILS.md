# 🛤️ Ruby on Rails on Cafaye OS

Cafaye OS is designed to be the ultimate environment for Ruby on Rails developers. It comes pre-configured with everything you need to build, test, and deploy Rails applications.

## 🚀 Getting Started

When you select "Ruby on Rails" during the installation wizard, Cafaye OS automatically handles:
- **Ruby Runtime**: System-wide Ruby installation.
- **Version Management**: `mise` comes pre-installed to manage multiple Ruby, Node.js, and Bun versions.
- **Databases**: PostgreSQL (default) and SQLite are pre-configured. MySQL/MariaDB can be enabled via the wizard.
- **Dependencies**: Critical libraries like `libyaml`, `vips`, `libxml2`, and `pkg-config` are ready.

## 🛠️ Typical Workflow

### 1. Version Management with `mise`
Cafaye uses `mise` (a faster `asdf` alternative) for runtime versions.
```bash
# Install a specific Ruby version
mise use ruby@3.3.0
```

### 2. Creating a new app
```bash
rails new myapp --database=postgresql
cd myapp
bundle install
bin/rails db:create
```

### 3. Database Services
PostgreSQL and Redis are managed as systemd services. You don't need to manually start them.
- **Postgres**: Always running on port 5432.
- **Redis**: Always running on port 6379 for Sidekiq/ActionCable.

## 💎 Premium Features for Rails Devs

### Zero-Config PostgreSQL
Cafaye creates a `cafaye` user with `trust` authentication for localhost. Your `database.yml` just works:
```yaml
development:
  adapter: postgresql
  database: myapp_development
  username: cafaye
  host: localhost
```

### Instant Sidekiq Setup
Redis is pre-configured and optimized for background jobs. Just add `sidekiq` to your Gemfile and point it to `redis://localhost:6379`.

### Optimized Terminal
Use `zellij` and `zsh` with `starship` for a beautiful, productive coding environment. Type `caf` to manage your system settings easily.

## 🧪 Testing
Running tests is fast thanks to the pre-configured ZRAM swap and optimized kernel.
```bash
bin/rails test
```
