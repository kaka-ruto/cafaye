# Remote AI Collaboration Workflow

## Objective
Support human + AI collaboration across local and remote nodes with consistent session visibility.

## Pattern
- Use main tmux session as control plane.
- Use fleet sessions to view active nodes.
- Run AI tasks on remote nodes while local workflow continues.

## Expected Behavior
- Operator can inspect all node sessions from one primary tmux entry point.
- AI tasks continue on remote nodes across local disconnects.
- Fleet status reflects current project/sync context.

## Safety
- Use trace IDs for cross-node operation correlation.
- Prefer resumable operations for long-running tasks.
- Keep secrets encrypted and out of logs.
