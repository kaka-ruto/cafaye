# 🚀 Cafaye: Development Guide

This document outlines the development workflow, phases, and guidelines for contributing to Cafaye.

## Development Philosophy

Cafaye is a **Development Runtime**—not an operating system. It provides reproducible, declarative development environments that work on Ubuntu, macOS, or any VPS.

### Core Principles

1. **Declarative Over Imperative**: Configuration as code, not shell scripts
2. **Modular Design**: Composable, reusable modules
3. **Test-Driven**: Every feature must have tests
4. **User-Friendly**: No Nix knowledge required to use
5. **Extensible**: Easy to add new languages, tools, or AI agents

---

## Development Phases

### Phase 1: Foundation (Current)
**Goal:** Core runtime working on Ubuntu and macOS.

- ✅ Nix installation automation
- ✅ Home Manager integration
- ✅ Basic CLI (caf commands)
- ✅ Module system architecture
- ✅ 5 core languages (Ruby, Python, Node, Go, Rust)
- ✅ 3 editors (Neovim, VS Code, Helix)
- ✅ Basic services (PostgreSQL, Redis, Docker)

**Status:** In Progress

### Phase 2: AI Platform
**Goal:** AI agent runtime and orchestration.

- Agent sandboxing
- Agent scheduling
- Support for Claude Code, Codex, Aider, etc.
- Background task execution

**Status:** Planned

### Phase 3: Polish
**Goal:** Developer experience improvements.

- More editor distributions
- More language versions
- Better error messages
- Documentation

**Status:** Planned

---

## Getting Started

### Prerequisites

- macOS or Linux development machine
- Git
- Basic understanding of Nix (helpful but not required)

### Setup

```bash
# Clone the repository
git clone https://github.com/kaka-ruto/cafaye.git
cd cafaye

# Enter development shell
# This provides all necessary tools
nix develop
# Or if you have direnv:
direnv allow
```

### Directory Structure

```
cafaye/
├── modules/          # Feature modules (languages, services, editors)
├── lib/             # Shared library functions
├── cli/             # CLI scripts and tools
├── tests/           # Test suite
├── docs/            # Documentation
└── user/            # User state and configuration
```

---

## Development Workflow

### 1. Making Changes

**Adding a new module:**

```bash
# 1. Create the module file
touch modules/languages/elm.nix

# 2. Write the module following the template
# See: modules/_template.nix

# 3. Write the test
touch tests/modules/languages/elm.nix

# 4. Run the test
nix build .#checks.x86_64-linux.modules-languages-elm

# 5. If it passes, commit
git add modules/languages/elm.nix tests/modules/languages/elm.nix
git commit -m "Add Elm language support"
```

**Modifying existing code:**

```bash
# 1. Make your changes
# 2. Run tests
./bin/test.sh

# 3. If adding a feature, add a test
# 4. Commit with clear message
git commit -m "Fix PostgreSQL service startup order"
```

### 2. Testing

**Fast feedback (local):**
```bash
# Static analysis
nix flake check --no-build

# Unit tests
./bin/test.sh

# Specific module test
nix build .#checks.x86_64-linux.modules-languages-ruby
```

**Full integration tests:**
```bash
# Run on remote forge (if available)
caf-test integration --remote

# Or locally with Docker
devbox run test-full
```

### 3. Debugging

**Test is failing:**
```bash
# Run with verbose output
nix build .#checks.x86_64-linux.modules-languages-ruby -L

# Interactive debugging
caf-test integration modules-languages-ruby --debug
```

---

## Contribution Guidelines

### Code Style

**Nix files:**
- 2 spaces for indentation
- Use `lib.mkIf` for conditional logic
- Add `meta` attribute to all modules

**Bash scripts:**
- Use `shellcheck` clean code
- Use `[[` instead of `[` for conditionals
- Quote all variables

**Git commits:**
- One-sentence commit messages
- No prefixes (feat:, fix:, etc.)
- Start with capital letter

### Module Guidelines

Every module must have:

1. **Meta information:**
```nix
meta = {
  name = "Module Name";
  description = "What this module does";
  category = "languages"; # or services, editors, ai
};
```

2. **Conditional logic:**
```nix
let
  enabled = userState.languages.ruby or false;
in
{
  config = lib.mkIf enabled {
    # Configuration here
  };
}
```

3. **Test coverage:**
```nix
# tests/modules/languages/ruby.nix
{ pkgs, ... }:

pkgs.testers.runNixOSTest {
  name = "ruby-module";
  testScript = ''
    machine.succeed("ruby --version")
    machine.succeed("gem --version")
  '';
}
```

### Pull Request Process

1. **Before submitting:**
   - Run `./bin/test.sh` locally
   - Ensure all tests pass
   - Update documentation if needed

2. **PR description:**
   - What changed
   - Why it changed
   - How to test it

3. **Review:**
   - Address feedback
   - Keep commits clean (squash if needed)

---

## Testing Strategy

### Test Layers

**Layer 1: Static Analysis** (Instant)
- Nix syntax checking
- JSON schema validation
- Shellcheck for bash

**Layer 2: Unit Tests** (Seconds)
- Module logic in isolation
- CLI command testing
- State management

**Layer 3: Integration Tests** (Minutes)
- Full VM tests with NixOS
- Multi-module scenarios
- Real service interactions

**Layer 4: Real-World Tests** (Hours)
- Fresh VPS provisioning
- End-to-end workflows
- Production-like scenarios

### Running Tests

```bash
# All tests
./bin/test.sh

# Specific layer
nix flake check --no-build                    # Static
caf-test unit                                  # Unit
caf-test integration                          # Integration
caf-test integration --remote                 # Real-world

# Specific module
nix build .#checks.x86_64-linux.modules-languages-ruby
```

---

## Release Process

See [RELEASING.md](RELEASING.md) for detailed release procedures.

---

## Questions?

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Read [TESTING.md](TESTING.md) for testing details
- Open an issue for discussion
