#!/usr/bin/env bash
# SessionStart hook: tell the session which StratoNext identity it runs as.
#
# The `stratonext` MCP server and CLI pick their mode from the same env pair: both
# STRATONEXT_AUTH_API_CLIENT_ID and STRATONEXT_AUTH_API_CLIENT_SECRET set means agent mode,
# anything else means user mode. Whatever this script prints on stdout is added to the
# session's context. It only tests that the variables are non-empty — it never prints them.
set -u

if [ -n "${STRATONEXT_AUTH_API_CLIENT_ID:-}" ] && [ -n "${STRATONEXT_AUTH_API_CLIENT_SECRET:-}" ]; then
  cat <<'MSG'
StratoNext identity for this session: AGENT.

This Claude Code session was started with an External agent credential
(STRATONEXT_AUTH_API_CLIENT_ID / STRATONEXT_AUTH_API_CLIENT_SECRET), so you ARE that StratoNext
agent: the `stratonext` MCP server and the `stratonext` CLI both authenticate as it, scoped to its
workspace. Do StratoNext work yourself — do not dispatch it to another agent.

- Track the work on a task assigned to you: `create_task` (it defaults to you), then
  `set_task_status` START to claim it, `report_task_progress` as you go, and COMPLETE with a
  result or FAIL with a reason. If the user points at a task already dispatched to you, claim that
  one instead of creating a new one.
- For cloud work on a tracked environment, get short-lived credentials from StratoNext instead of
  using any local cloud profile. In Bash, issue them inside the same command that uses them, so
  they never appear in the conversation or on disk:
  eval "$(uvx stratonext@latest credential issue --environment-id <env_id> --format env)" && aws ...
- On a permission wall, stop and call `request_credential_escalation` on your task with the
  narrowest actions and resource ARNs. APPROVED: redeem it with `--approval-id <id>` on the issue
  command. PENDING: tell the user a human must decide in the StratoNext web app, and wait — do not
  poll, retry, or work around it.
- Never approve or reject an approval, never persist issued credentials, and never print the
  agent's client secret.

Load the `stratonext:stratonext` skill before your first StratoNext action.
MSG
else
  cat <<'MSG'
StratoNext identity for this session: USER.

The `stratonext` MCP server and CLI act as the human signed in with `stratonext login` (run the
`stratonext:setup` skill if they are not signed in). StratoNext issues no cloud credentials to a
user session: work that has to act inside a cloud account is dispatched to a StratoNext agent —
create a task assigned to the agent and START it (that dispatches it), then read back its result.
Never set STRATONEXT_AUTH_API_CLIENT_ID / _SECRET or run as an agent to obtain credentials.

Load the `stratonext:stratonext` skill before your first StratoNext action.
MSG
fi
