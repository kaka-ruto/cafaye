# Security Model

This document defines Cafaye security assumptions, trust boundaries, and threat model.

## Security Objectives
- Keep secrets encrypted at rest.
- Minimize blast radius across distributed nodes.
- Preserve reproducibility without exposing sensitive state.
- Provide auditable operations across fleet workflows.

## Trust Boundaries
- Local operator machine: trusted for key management.
- Remote fleet nodes: trusted for execution, not for source-of-truth authority.
- Git remote: trusted for version history, not for plaintext secrets.
- CI runners: untrusted with plaintext secrets unless explicitly provisioned.

## Threat Assumptions
- Attackers may read Git history and CI logs.
- Attackers may gain shell access to a single fleet node.
- Network paths may be hostile; transport security is mandatory.
- Operator mistakes (bad key handling, accidental logging) are realistic risks.

## Non-Goals
- Defending against fully compromised operator endpoints.
- Defending against kernel-level compromise on all nodes simultaneously.

## Core Controls
- Secrets encrypted with SOPS; never committed in plaintext.
- SSH/Tailscale-first remote access model.
- Structured logs with redaction controls.
- Traceable operations with correlation IDs.
- Declarative rebuild and rollback workflows.

## Key Management
- Use dedicated SSH keys for Cafaye node operations.
- Convert SSH keys to age identities for SOPS workflows.
- Maintain recipient lists in `.sops.yaml`.
- Rotate recipients when people/nodes leave trust boundary.

## Secret Handling Rules
- Never print secrets to terminal, logs, or CI output.
- Never store unencrypted secrets in repo files.
- Rotate secrets when exposure is suspected.
- Validate decryption only where required for runtime.

## Remote Operations Safety
- Prefer non-interactive, bounded-time remote commands.
- Handle partial node failures without cascading operations.
- Require explicit confirmation for destructive operations.

## CI Safety Expectations
- CI should run without requiring plaintext secret exposure.
- Failure logs must provide debugging context without leaking secrets.
- Artifacts should include operational diagnostics only.

## Incident Response (Minimum)
1. Identify affected node/key/secret scope.
2. Revoke compromised access (key/recipient/node).
3. Rotate impacted secrets and recipients.
4. Rebuild/sync fleet from trusted source state.
5. Verify logs and trace IDs for containment evidence.
