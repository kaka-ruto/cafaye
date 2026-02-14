# Team Onboarding Model

## Shared Baseline + Personal Overrides
- Team baseline lives in shared Cafaye repo defaults.
- Each engineer keeps personal overrides in `config/user/`.
- Shared repo remains reproducible while preserving local preferences.

## Onboarding Flow
1. Clone team Cafaye repository.
2. Bootstrap using reproducible install flow.
3. Apply shared baseline.
4. Add personal overrides in user layer only.
5. Validate with CI and fleet status checks.

## Operational Expectations
- Team changes go through PR + CI gates.
- Personal overrides do not require team-wide rebuilds.
- Fleet nodes remain consistent with baseline state.
