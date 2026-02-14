# Reproducibility and Safe Upgrades

## Reproduce Environment from Git
Use Cafaye bootstrap to recreate an environment from Git source state.

```bash
caf-bootstrap-from-git <repo-url> [ref]
```

Expected behavior:
- Clones the selected repository/ref to `~/.config/cafaye`.
- Backs up existing install if replacing.
- Runs installer from cloned source for deterministic setup.

## Safe Upgrade Path
Use state-preserving upgrade flow:

```bash
caf-upgrade-safe
```

Expected behavior:
- Backs up state-critical paths before update.
- Pulls latest on current branch.
- Rebuilds environment.
- Restores preserved state if rebuild fails.

## Safety Flags
- `--dry-run`: preview without mutating state.
- `--yes`: non-interactive confirmation bypass.

## Operational Notes
- Treat Git as source-of-truth for reproducible setup.
- Keep user customizations in `config/user/`.
- Keep encrypted secrets in `secrets/`.
