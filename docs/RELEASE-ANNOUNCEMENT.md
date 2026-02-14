# Cafaye Release Announcement and Upgrade Guidance

## Release Message Draft
`Cafaye` is now release-candidate ready as a distributed, reproducible developer infrastructure layer for Linux and macOS.

This candidate focuses on core infrastructure reliability:
- deterministic workspaces and tmux orchestration
- AstroNvim-first editor defaults with safe recovery paths
- robust zsh/tmux/terminal navigation behavior
- secure fleet operations with least-privilege SSH defaults
- single-VM behavioral integration testing and cross-platform CI smoke coverage

## Who Should Upgrade
- Users already running Cafaye on Linux or macOS.
- Teams managing multiple remote development nodes.
- Operators who need reproducible bootstrap and safe rollback upgrade paths.

## Upgrade Path
1. Ensure your local changes are committed/pushed.
2. Run `caf upgrade safe`.
3. Validate state with:
   - `caf status`
   - `caf system doctor`
   - `caf fleet status` (if using fleet)
4. For editor recovery issues, run:
   - `caf nvim distribution setup --doctor`
   - `caf nvim distribution setup --repair` (if required)

## Post-Upgrade Verification
- Workspace plan check: `caf workspace run --dry-run`
- Sync predictability check: `caf sync pull --dry-run`
- Rebuild dry-run check: `caf system rebuild --dry-run`
- Performance sanity check: `caf perf audit`

## Rollback Guidance
If upgrade fails, use the state/backup artifacts created by `caf upgrade safe` and rerun the previous known-good revision from git.

## Known Release Blockers
- Branch protection enforcement in GitHub repository settings.
- Final timed first-install baseline on low/medium VPS SKUs.

## Reviewer Checklist
- Verify command examples match current CLI names.
- Confirm docs links and migration notes are aligned.
- Confirm CI green for candidate commit before announcement.
