# 🧪 Cafaye OS: Rails Framework Verification

This document walkthroughs the end-to-end setup and usage of Cafaye OS for a Ruby on Rails developer.

## 1. Installation
The developer runs the `install.sh` and selects:
- [x] Ruby on Rails
- [x] PostgreSQL
- [x] Docker

## 2. Environment Verification
Once logged in, the developer checks the pre-configured tools:

```bash
# Verify Ruby (provided by system)
ruby -v

# Verify Rails (pre-installed for immediate use)
rails -v

# Verify Mise (version manager)
mise -v

# Verify PostgreSQL
psql -c "SELECT version();"
```

## 3. Creating a Multiple-Ruby Setup
Devs often need different rubies for different projects.

```bash
# Install a new Ruby version
mise use ruby@3.2.2

# Check versions
ruby -v
```

## 4. Building a Full-Stack Rails App
The developer creates a new app with Postgres and Redis.

```bash
rails new awesome_app --database=postgresql
cd awesome_app

# The 'cafaye' db user is pre-trusted
bin/rails db:create
bin/rails db:migrate

# Start the dev server
bin/rails server
```

## 5. Using Backing Services
- **PostgreSQL**: Managed by systemd, optimized for dev.
- **Redis**: Ready for Sidekiq/ActionCable.
- **MySQL**: (If enabled) MariaDB drop-in toolset.

## 6. Developer Experience
- **Terminal**: `zellij` and `zsh` with `starship` make the terminal feel like a high-end IDE.
- **Security**: Kernel-hardened and SSH brute-force protected by default.
- **Reproducibility**: This exact environment can be replicated on any VPS with one command.
