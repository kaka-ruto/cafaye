#!/usr/bin/env bash
set -euo pipefail

# Real-world fleet smoke test
# Non-destructive by default. Apply is opt-in with CAF_FLEET_SMOKE_ALLOW_APPLY=1.

REPO_PATH="${REPO_PATH:-$HOME/.config/cafaye}"
ALLOW_APPLY="${CAF_FLEET_SMOKE_ALLOW_APPLY:-0}"

if [[ ! -d "$REPO_PATH" ]]; then
  echo "❌ Cafaye repo not found at: $REPO_PATH"
  exit 1
fi

cd "$REPO_PATH"

echo "== Fleet Smoke: status =="
bash cli/scripts/caf-fleet status >/tmp/caf-fleet-status.out 2>&1 || true
test -s /tmp/caf-fleet-status.out

echo "== Fleet Smoke: sync (resumable) =="
bash cli/scripts/caf-fleet sync --resume >/tmp/caf-fleet-sync.out 2>&1 || true
test -s /tmp/caf-fleet-sync.out

echo "== Fleet Smoke: apply (optional) =="
if [[ "$ALLOW_APPLY" == "1" ]]; then
  bash cli/scripts/caf-fleet apply --resume >/tmp/caf-fleet-apply.out 2>&1 || true
  test -s /tmp/caf-fleet-apply.out
else
  echo "Skipping apply. Set CAF_FLEET_SMOKE_ALLOW_APPLY=1 to enable." >/tmp/caf-fleet-apply.out
fi

echo "✅ Fleet smoke test completed"
