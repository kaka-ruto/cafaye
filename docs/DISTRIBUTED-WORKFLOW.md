# Distributed Workflow

This guide defines the day-to-day workflow for running Cafaye across local and remote nodes.

## Goals
- Keep all nodes reproducible from Git.
- Avoid configuration drift.
- Make node state and fleet health explicit.

## Prerequisites
- Tailscale connectivity between nodes.
- `~/.config/cafaye` present on each node.
- Fleet registry decrypted locally (`secrets/fleet.yaml`).

## Fleet Setup
1. Create or provision a remote node.
2. Ensure node has Cafaye installed and reachable.
3. Add node to fleet registry with role and IP.
4. Verify fleet view shows identity, role, and reachability.

Expected behavior:
- `caf fleet status` lists each node with role and project context.
- Unreachable nodes are clearly labeled and do not block healthy nodes.

## Daily Flow
1. Work locally and commit changes to Cafaye repo.
2. Push source-of-truth changes.
3. Sync and apply changes across fleet.
4. Verify status and drift.

Expected behavior:
- Sync/apply gives per-node success/failure summaries.
- Partial failures are visible without masking successful nodes.
- Rebuild logs include trace IDs for cross-node correlation.

## Multi-Node Workspace Flow
1. Start workspace from a node with fleet access.
2. Validate generated windows/session plan with dry-run.
3. Attach to fleet session when needed.

Expected behavior:
- Workspace creation is deterministic from config.
- Session/window naming is stable.
- Fleet windows are not duplicated unexpectedly.

## Troubleshooting
- Fleet registry decryption failure:
  - Verify SOPS key availability and recipients.
  - Validate `secrets/fleet.yaml` is decryptable JSON/YAML.
- Node appears unreachable:
  - Verify Tailscale IP and SSH key.
  - Validate host-level firewall and Tailscale status.
- Sync conflicts:
  - Resolve git rebase conflict on affected node.
  - Re-run sync after conflict resolution.
- Rebuild failures:
  - Inspect rebuild logs with matching trace ID.
  - Retry once network issues are resolved.

## Operational Guardrails
- Never edit Cafaye-managed defaults in place on remote nodes.
- Keep user customizations in user-owned config paths.
- Treat Git as source of truth for reproducibility.
- Keep secrets encrypted at rest and out of logs.
