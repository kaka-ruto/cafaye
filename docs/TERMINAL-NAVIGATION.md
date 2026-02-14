# Terminal Navigation Defaults

Cafaye provides navigation defaults designed for common engineering workflows.

## Core Behaviors
- Consistent directory traversal aliases:
  - `..` -> parent directory
  - `...` -> two levels up
  - `....` -> three levels up
  - `-` -> previous working directory
- Fuzzy directory jump helper:
  - `cdf` opens interactive directory selection (via `c` helper)
  - Falls back to `cd` when helper tools are unavailable

## Keybindings
- `Alt+j` -> jump directory (`cdf`)
- Existing Cafaye action bindings remain unchanged (`Alt+s`, `Alt+r`, etc.)

## UX Expectations
- Navigation defaults work the same in local terminals and SSH sessions.
- Missing optional tools should degrade gracefully (no shell breakage).
- Navigation remains keyboard-first for fast context switching.

## Related Helpers
- `c`: interactive directory picker using `fd + fzf`
- `tm`: interactive tmux session picker
- `tat`: project-aware tmux session helper
