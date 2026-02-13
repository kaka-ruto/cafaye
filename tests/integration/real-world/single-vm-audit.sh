#!/usr/bin/env bash
set -euo pipefail

# Reusable single-VM release audit for Cafaye.
# Uses one instance for the entire suite to keep runtime/cost low.

INSTANCE_NAME="${INSTANCE_NAME:-cafaye-vps-test}"
ZONE="${ZONE:-us-central1-a}"
REPO_PATH="${REPO_PATH:-~/.config/cafaye}"

echo "== Cafaye Single-VM Audit =="
echo "instance: ${INSTANCE_NAME}"
echo "zone: ${ZONE}"
echo "repo: ${REPO_PATH}"

run_remote() {
  gcloud compute ssh "$INSTANCE_NAME" --zone "$ZONE" --command "$1"
}

echo "== Validate VM availability =="
run_remote "hostname >/dev/null"

echo "== Sync repo and run lint/flake checks =="
run_remote "set -euo pipefail; cd ${REPO_PATH}; git fetch origin; git checkout master; git pull --ff-only origin master; bash bin/test.sh --lint"

echo "== Runtime smoke matrix (terminal/editor/fleet/workspace) =="
run_remote "set -euo pipefail; cd ${REPO_PATH}; \
for c in tmux zsh nvim lazygit jq gum; do command -v \$c >/dev/null || { echo \"missing \$c\"; exit 1; }; done; \
bash cli/scripts/caf-version >/dev/null; \
bash cli/scripts/caf-status >/dev/null; \
bash cli/scripts/caf-search status >/dev/null; \
bash cli/scripts/caf-fleet status >/dev/null; \
bash cli/scripts/caf-project list >/dev/null || true; \
tmux -V >/dev/null"

echo "== Single-VM audit complete =="
