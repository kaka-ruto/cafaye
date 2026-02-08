# Contributing to Cafaye OS

We're excited that you're interested in contributing to Cafaye OS! ☕

## Getting Started

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/kaka-ruto/cafaye
   cd cafaye
   ```
2. **Setup Development Environment**:
   - Install **Devbox** or **Nix**.
   - Use `devbox shell` to enter a reproducible environment with all tools (Nix, Git, editors, etc.).

## Workflow

We follow a structured workflow for changes:

1. **Edit**: Make your changes in the appropriate directory (e.g. `modules/`, `interface/`, `cli/`).
2. **Test**:
   - Run local tests: `./bin/test.sh` (fast VM boot test)
   - Or specific test: `nix build .#checks.x86_64-linux.integration-rails`
3. **Commit**: Use descriptive commit messages.

## Project Structure

- **`core/`**: Base NixOS configuration (boot, hardware, networking).
- **`modules/`**: Modular features (services, languages, editors).
- **`interface/`**: User interface configuration (terminal, DE/WM).
- **`cli/`**: Custom CLI tools and scripts (`caf-*`).
- **`tests/`**: VM integration tests.

## Coding Standards

- **Nix**: Use standard Nix formatting (nixfmt). Avoid deeply nested logic in expressions.
- **Bash Scripts**: Ensure scripts are POSIX compliant where possible, or bash-specific if using modern features. Use `set -e` for safety.
- **Documentation**: Keep `DEVELOPMENT.md` and `docs/` updated.

## Pull Requests

1. **Title**: Clear and concise description.
2. **Description**: Explain *why* the change is needed.
3. **Checklist**: Ensure tests pass locally before submitting.

---

**Thank you for helping make Cafaye OS better!** 🚀
