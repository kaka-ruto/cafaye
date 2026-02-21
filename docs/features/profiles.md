# Cafaye Profiles

This document defines the `Cafaye Profiles` feature: isolated, reproducible Cafaye installations composed from shared modules plus profile-specific overlays.

## Goals

- Keep personal and project/agent infrastructure configurations separated.
- Make any profile reproducible from versioned config.
- Support full profile lifecycle operations (Create, Read, Update, Delete).
- Prevent cross-profile state, secret, and runtime collisions.

## Non-Goals

- Runtime auto-migration of arbitrary unmanaged files.
- One-click production deploy without review gates.
- Storing plaintext secrets in profile config.

## Core Behavior

- A profile represents a full Cafaye installation intent for a specific context (for example `personal`, `openclaw-dev`, `openclaw-prod`).
- Each profile is built from:
  - Shared base modules (`common`).
  - Optional feature packs (`security`, `observability`, `desktop`, etc.).
  - Profile overlay (`profiles/<name>/`), which is the only place profile-specific config should live.
- Profile activation generates profile-scoped outputs and state paths.
- A profile can be validated without applying changes (dry-run/plan mode).
- Profiles must be idempotent: re-applying the same profile should produce no unintended drift.

## Architecture

### Directory Model

```text
cafaye/
  profiles/
    personal/
      profile.nix
      settings.json
      secrets.refs.yaml
      README.md
    openclaw-dev/
      profile.nix
      settings.json
      secrets.refs.yaml
      README.md
    openclaw-prod/
      profile.nix
      settings.json
      secrets.refs.yaml
      README.md
  modules/
    common/
    security/
    observability/
    openclaw/
```

### Profile Contract

Each profile should define:

- `name`: immutable identifier.
- `inherits`: ordered list of base modules/profiles.
- `packages`: package set for this profile.
- `services`: enabled services and per-service config.
- `secretsRefs`: references to external secret providers/paths.
- `stateRoot`: profile-specific state directory.
- `policy`: guardrails (for example allow/deny destructive actions).

### Isolation Rules

- Separate state paths per profile (`~/.local/state/cafaye/<profile>`).
- Separate cache paths per profile when needed.
- Separate secret namespaces and key names per profile.
- No shared mutable profile outputs unless explicitly marked read-only and shared.

## Build Model

### Build Steps

1. Resolve profile manifest and inheritance.
2. Merge modules and overlay config with deterministic precedence.
3. Validate schema and guardrails.
4. Render final installation plan.
5. Apply (or dry-run only).
6. Write profile lock/metadata for reproducibility.

### Merge Precedence

1. `modules/common`
2. feature modules (in declared order)
3. profile overlay (`profiles/<name>/*`)
4. CLI/runtime flags (temporary, non-persisted unless explicitly saved)

### Reproducibility Requirements

- Version all profile definitions in Git.
- Pin package/module inputs where possible.
- Persist resolved metadata (`profile.lock` or equivalent).
- Record build timestamp and Cafaye version in metadata.

## Profile Lifecycle (CRUD)

### Create

- Create profile scaffold from template.
- Validate unique profile name and path.
- Require explicit base inheritance declaration.
- Initialize profile README with purpose, owner, and environment scope.

### Read

- List available profiles and active profile.
- Show resolved configuration (redacting sensitive values).
- Show effective module graph and inheritance chain.
- Show drift status: desired config vs current state.

### Update

- Support safe edits to profile overlay and module assignments.
- Validate schema before apply.
- Produce plan diff before mutating runtime state.
- Require confirmation for high-risk changes (service removal, data path changes, secret key rotation bindings).

### Delete

- Support soft-delete (disable profile, keep state).
- Support hard-delete (remove profile files and optionally state).
- Require explicit confirmation phrase for hard-delete.
- Block delete when profile is active unless `--force` and confirmation are provided.

## CLI Expectations

```text
cafaye profile create <name> --from-template <template>
cafaye profile list
cafaye profile show <name> [--resolved]
cafaye profile diff <name>
cafaye profile apply <name> [--dry-run]
cafaye profile update <name> [flags...]
cafaye profile delete <name> [--hard --purge-state]
cafaye profile switch <name>
```

## Security and Hardening

- Secrets are references only; secret material is loaded at runtime from external providers.
- Default profile policy is least-privilege.
- Profiles can enforce approval gates for destructive operations.
- All apply operations log who/what/when metadata.

## OpenClaw-Oriented Usage

- `openclaw-dev` profile: rapid iteration, lower blast radius, verbose logging.
- `openclaw-prod` profile: strict policies, review gates, tighter networking and execution permissions.
- Keep Slack agent routing, tool permissions, and execution policies in profile overlay config.

## Progress Tracker

### Foundation

- [ ] Define profile schema (`name`, `inherits`, `services`, `secretsRefs`, `policy`, `stateRoot`).
- [ ] Add schema validation command and CI check.
- [ ] Implement deterministic merge/precedence engine.
- [ ] Add profile metadata/lock generation.

### Scaffolding and Templates

- [ ] Add `cafaye profile create` scaffold command.
- [ ] Add starter templates (`personal`, `openclaw-dev`, `openclaw-prod`).
- [ ] Generate per-profile README on creation.
- [ ] Add naming and uniqueness validation.

### Read Operations

- [ ] Add `cafaye profile list`.
- [ ] Add `cafaye profile show --resolved` with redaction.
- [ ] Add module graph/inheritance visualization output.
- [ ] Add drift check command/output.

### Update Operations

- [ ] Add `cafaye profile update` command.
- [ ] Add plan/diff preview before apply.
- [ ] Add confirmation prompts for high-risk mutations.
- [ ] Add rollback metadata/snapshots for failed applies.

### Delete Operations

- [ ] Add soft-delete behavior.
- [ ] Add hard-delete with confirmation phrase.
- [ ] Add optional state purge flow.
- [ ] Add active-profile delete protection.

### Activation and Runtime

- [ ] Add `cafaye profile switch` active-profile selector.
- [ ] Isolate runtime paths (state/cache/logs) by profile.
- [ ] Prevent cross-profile secret namespace collisions.
- [ ] Add profile-aware logging metadata.

### Security

- [ ] Enforce no-plaintext-secrets rule in profile files.
- [ ] Add least-privilege defaults for execution policies.
- [ ] Add audit log entries for apply/delete/switch operations.
- [ ] Add policy checks for production-class profiles.

### Testing

- [ ] Unit tests for schema validation and merge precedence.
- [ ] Integration tests for create/list/show/apply/switch/delete.
- [ ] Negative tests for collision, invalid schema, and forbidden delete.
- [ ] Reproducibility test: rebuild profile from clean host/state.

## Definition of Done

- [ ] Any profile can be created from template and applied on a clean machine.
- [ ] Read commands expose resolved state without leaking secrets.
- [ ] Update and delete flows are safe, auditable, and policy-gated.
- [ ] Profile isolation guarantees no unintended cross-profile contamination.
- [ ] CI enforces schema validity and reproducibility checks.
