# CHANGES

Release-readiness checklist for Cafaye distributed development infrastructure.

## Core Platform Readiness
- [x] Fresh install succeeds on supported Linux hosts with no manual recovery steps.
- [x] Fresh install succeeds on supported macOS hosts with no manual recovery steps.
- [x] Installer is idempotent and can be safely re-run without data loss.
- [x] Installer pre-fills form fields with existing state when re-run.
- [ ] Upgrade path from previous versions preserves state, configs, and workflows.
- [x] Uninstaller exists and safely removes Cafaye with backups.
- [x] Default setup is production-safe and works for first-time users out of the box.

## Reproducibility and State Management
- [ ] Entire environment can be reproduced from git state on a new machine.
- [x] User customizations and Cafaye defaults are clearly separated and never conflict.
- [x] Drift detection clearly reports when runtime state differs from declared state.
- [x] Sync/pull/push workflows are reliable across laptop and remote nodes.
- [x] Recovery from interrupted sync/rebuild leaves system in a consistent state.
- [x] Install logs are redacted and safe to share for debugging.
- [x] State files are validated and corrupted state is detected with actionable guidance.

## Distributed Fleet Operations
- [x] Fleet node registration and removal are reliable and auditable.
- [x] Fleet status reports are accurate for reachable and unreachable nodes.
- [x] Fleet apply operations show clear per-node success/failure outcomes.
- [x] Partial fleet failures do not block healthy nodes from completing operations.
- [x] Fleet attach/switch workflows are stable across many concurrent nodes.
- [x] Node identity, role, and current project context are always unambiguous.

## Workspace Orchestration
- [x] Workspace definitions are customizable via user-owned config only.
- [x] Workspace startup is deterministic across local and remote hosts.
- [x] Dry-run mode always reports exact session/window/command plan.
- [x] Invalid workspace configs fail fast with actionable validation errors.
- [x] Default workspace works even when optional tools are unavailable.
- [x] Multi-node workspace behavior is predictable and does not duplicate windows.

## Terminal and Shell Experience
- [x] tmux startup, session reuse, and keybindings are consistent across platforms.
- [x] zsh startup is fast and deterministic with no noisy errors.
- [ ] Terminal navigation defaults are coherent for common engineering workflows.
- [x] Core terminal UX works in headless, SSH, and local GUI contexts.
- [x] Lazygit integration works with declared git repos and sane defaults.
- [x] Ghostty behavior degrades gracefully on systems where it is unsupported.

## Editor Experience (AstroNvim-first)
- [x] AstroNvim boots cleanly with Cafaye defaults and user overrides.
- [x] Plugin pinning and update behavior are deterministic and reproducible.
- [x] Editor distribution switching is safe and reversible.
- [x] LSP/tooling defaults work for major stacks without manual patching.
- [x] Local and remote editor experiences are consistent for core workflows.
- [x] Broken plugin states are detected and recoverable without manual surgery.

## Security and Secrets
- [x] Secrets are encrypted at rest and never committed to version control.
- [x] Secret rotation workflows are documented and tested.
- [x] SOPS integration works reliably across local and remote nodes.
- [x] Sensitive data is never leaked to logs, terminal history, or CI artifacts.
- [ ] Principle of least privilege is enforced for scripts and remote operations.
- [ ] Supply chain integrity checks exist for critical dependencies.
- [x] Secure defaults are enforced for SSH and remote execution pathways.

## Reliability, Errors, and Recovery
- [x] All core CLI commands return stable exit codes and human-actionable errors.
- [x] Transient network failures are retried with bounded backoff and clear logs.
- [x] Long-running operations provide progress and cancellation safety.
- [x] Timeouts are explicit and tuned for CI and real-world remote hosts.
- [x] Interrupted operations can resume or safely restart without data loss.
- [x] System doctor diagnostics can identify and prioritize root causes.

## Testing Architecture and Coverage
- [x] Single-VM integration test suite covers all core infra behaviors end-to-end.
- [x] Integration tests avoid spawning multiple nested VMs for behavioral coverage.
- [x] Unit tests cover command parsing, config resolution, and failure handling.
- [x] Cross-platform test matrix validates Linux and macOS critical paths.
- [x] Tests assert expected behavior, not implementation details.
- [x] Test runtime is bounded and fast enough for PR feedback loops.
- [ ] Flaky tests are tracked, quarantined, and driven to zero.
- [ ] Real-world smoke tests validate fleet workflows against remote hosts.
- [x] Fresh install test suite validates installer on clean VPS/VM.

## CI/CD and Release Gates
- [x] CI runs on every PR and on every push to the main branch.
- [x] Required checks enforce lint, unit, behavioral integration, and packaging gates.
- [x] CI status tooling can fetch latest/commit-specific runs with logs in one command.
- [x] Failed CI jobs provide enough diagnostics to debug without reruns.
- [ ] Release builds are reproducible and signed where applicable.
- [ ] Versioning, changelog generation, and release notes are consistent and automated.
- [ ] Branch protections prevent unreviewed or failing changes from merging.

## Performance and Scale
- [ ] First-time setup time is acceptable on low/medium compute VPS instances.
- [ ] Incremental rebuild/sync times are predictable for daily use.
- [ ] Fleet status and orchestration remain responsive at higher node counts.
- [x] Startup latency for shell/tmux/editor remains within target budgets.
- [ ] Heavy operations avoid unnecessary downloads and duplicate work.
- [ ] Cache strategy materially improves CI and user install performance.

## Observability and Diagnostics
- [x] Structured logs exist for install, update, sync, and fleet workflows.
- [x] Log verbosity can be adjusted without losing essential diagnostics.
- [x] Diagnostic bundles are safe to share and redact sensitive material.
- [x] Health commands provide concise summary plus deep-dive details.
- [x] Failure telemetry can be correlated across local and remote nodes using Trace IDs.

## Documentation and Onboarding
- [x] Getting-started docs lead a new user to productive setup without support.
- [x] Supported OS versions, limitations, and known constraints are explicit.
- [x] Migration guides exist for users coming from other dotfile/dev-env systems.
- [x] Customization docs clearly explain what users should and should not edit.
- [x] Distributed workflow docs cover fleet setup, daily flow, and troubleshooting.
- [x] Security model and threat assumptions are clearly documented.

## Product and Ecosystem Fit
- [ ] Default templates cover major engineer personas and common stack combinations.
- [ ] Extensibility model supports user modules/extensions without fork pressure.
- [ ] Team onboarding flow supports shared baselines plus personal overrides.
- [ ] Remote node workflows support AI-agent and human collaboration patterns.
- [ ] Core UX remains stable as optional modules are added or removed.

## Governance and Maintenance
- [ ] Clear ownership exists for core modules, CI, docs, and release operations.
- [ ] Incident process exists for regressions affecting install or fleet operations.
- [ ] Backward-compatibility policy is defined and enforced.
- [ ] Deprecation policy includes migration windows and communication standards.
- [ ] Support model and response expectations are defined for community users.

## Final Release Decision
- [ ] All release-blocking checklist items above are complete.
- [ ] No open critical or high-severity defects remain in core infra paths.
- [ ] Candidate release is validated on fresh Linux and macOS environments.
- [ ] Candidate release is validated on at least one real multi-node fleet setup.
- [ ] Release announcement and upgrade guidance are prepared and reviewed.
