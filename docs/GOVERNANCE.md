# Governance and Maintenance

## Ownership
- Core modules: maintainers group
- CI/CD workflows: release/infrastructure maintainers
- Documentation: docs maintainers
- Security workflows: security maintainers

## Incident Process
1. Triage severity and impacted workflows.
2. Assign incident owner.
3. Mitigate with rollback/revert/fix-forward.
4. Publish postmortem with action items.

## Backward Compatibility
- Minor releases preserve config/schema compatibility by default.
- Breaking changes require migration documentation.

## Deprecation Policy
- Mark deprecated behavior before removal.
- Provide migration window and clear replacement path.
- Remove only after documented deprecation cycle.

## Support Model
- Community support via issues/discussions.
- Critical install/fleet regressions prioritized.
- Release notes include known issues and mitigations.
