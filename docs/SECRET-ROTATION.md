# Secret Rotation Runbook

This runbook defines the standard Cafaye secret rotation workflow.

## Scope
- Application/API secrets stored via SOPS.
- Fleet registry decryption recipients.
- SSH/age keys used for distributed operations.

## Rotation Triggers
- Scheduled periodic rotation.
- Team membership or device changes.
- Suspected or confirmed secret exposure.
- Node compromise or decommission.

## Rotation Workflow
1. Identify secrets and recipients to rotate.
2. Add new keys/recipients first.
3. Re-encrypt affected SOPS files.
4. Distribute updated encrypted state via Git.
5. Validate decrypt/read behavior on required nodes.
6. Remove deprecated recipients.
7. Re-encrypt and re-validate.

Expected behavior:
- New recipients can decrypt before old recipients are removed.
- Removed recipients can no longer decrypt after final rotation step.
- Fleet operations continue on authorized nodes without plaintext leakage.

## Validation Checklist
- `secrets/fleet.yaml` decrypts for authorized operator identity.
- Unauthorized/removed recipient decryption fails.
- Fleet status and apply still function for authorized operators.
- CI/lint/test output contains no plaintext secret leakage.

## Rollback Plan
- Re-add previous recipient if lockout occurs.
- Restore last known-good encrypted file from Git.
- Re-run validation before removing any recipient again.

## Operational Notes
- Rotate one trust boundary at a time (humans, then nodes).
- Avoid concurrent unrelated infra changes during rotation windows.
- Record rotation date, operator, and impacted assets.
