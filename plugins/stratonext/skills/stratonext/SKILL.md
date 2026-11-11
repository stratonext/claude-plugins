---
name: stratonext
description: Work with the StratoNext platform — projects, tasks, task templates, approvals, environments, signals, reports and assets, and cloud work on a tracked environment. Use whenever the user asks to look up, create or update anything in StratoNext, check work assigned to them, operate on a cloud account StratoNext tracks, hand work to a StratoNext agent, or follow up on a task or approval.
---

# Working with StratoNext

StratoNext is an Agentic Operations Platform: trusted AI agents do production work alongside
human teams, under workspace roles, approvals and an audit trail.

## 1. Know which identity this session has

The session runs as exactly one of two identities, fixed when Claude Code started. The plugin's
session-start note says which ("StratoNext identity for this session: AGENT" or "USER"). If that
note is missing, check without printing any value:

```bash
[ -n "$STRATONEXT_AUTH_API_CLIENT_ID" ] && [ -n "$STRATONEXT_AUTH_API_CLIENT_SECRET" ] && echo agent || echo user
```

`whoami` from the `stratonext` MCP server confirms it (`authMode`). The MCP server, the CLI and
this skill all follow the same rule: both variables set means **agent**, anything else means
**user**. Nothing else matters — not whether a person is at the keyboard, not who asked. The
credential is part of how the session was started; do not export or unset it mid-session.

Then follow the section for that identity.

## 2a. Agent identity — do the work yourself

The credential is present, so this session **is** a registered StratoNext External agent, scoped
to one workspace — even when a person is typing the requests. It gets cloud credentials from
StratoNext directly, so do the work here; never dispatch it to another agent instead.

1. **Put the work on a task assigned to you.** If the user names a task already dispatched to you,
   use it (`list_tasks` with `mine=true` shows them). Otherwise ask which project or environment it
   is for, then `create_task` — it assigns the task to you by default.
2. **Claim it** with `set_task_status` START. A conflict means another worker on the same
   credential has it: stop, do not create a duplicate.
3. **Gather context**: `get_task`, `get_project` (deployments, graph, region) and
   `get_environment` for each environment you will touch.
4. **Get credentials for the environment.** Base access needs no approval. Prefer the CLI in Bash,
   issued inside the same command that uses them, so the keys never enter the conversation and are
   never written to disk:

   ```bash
   eval "$(uvx stratonext@latest credential issue --environment-id <env_id> --format env)" && aws sts get-caller-identity
   ```

   Each Bash call starts clean, so repeat the `eval … &&` prefix on every command that needs them
   (they are short-lived; issuing again is expected). Use the region from the environment or
   deployment. The `issue_credentials` MCP tool returns the same credentials as data — use it only
   when nothing in Bash needs them, and never echo, save or paste them anywhere.
5. **Report progress** with `report_task_progress` as you go, so humans can follow the work.
6. **Permission wall** (AccessDenied, 403, a missing IAM right): stop. Do not retry with other
   credentials, use a local cloud profile, or do a partial version that dodges the permission.
   Call `request_credential_escalation` on your task with the narrowest actions and resource ARNs
   and a precise reason.
   - **APPROVED**: redeem it — add `--approval-id <approval_id>` to the `credential issue` command.
   - **PENDING**: tell the user it is waiting on a human decision in the web app
     (https://app.stratonext.com) and stop. Do not poll or retry. Once they say it is approved,
     re-read the task with `get_task`, claim it again with START if it was re-dispatched, and
     redeem the approval.
   - **REJECTED**: FAIL the task with a reason naming what was blocked.
7. **Finish**: `set_task_status` COMPLETE with a result (what was done, where the output is), or
   FAIL with a reason. Re-read the task with `get_task` on long work; if it was CANCELLED, stop.

## 2b. User identity — dispatch cloud work to an agent

This session acts as the human signed in with `stratonext login`, across all their workspaces.
StratoNext gives a user session context, never cloud credentials. If a tool says the user is not
signed in, run the `setup` skill (`/stratonext:setup`).

- **Platform work** (look up, create or update projects, tasks, templates, signals, reports,
  assets): do it with the MCP tools directly.
- **Work that must act inside a cloud account** (deploy, fix, inspect or change resources in a
  tracked environment): dispatch it to a StratoNext agent.
  1. Find the project or environment and an agent that works it (`whoami`, `get_project`,
     `get_environment`); ask the user if more than one fits.
  2. Confirm with the user, then `create_task` with clear `description` / `instructions`,
     `assignee_id` = the agent and `assignee_type` = AGENT.
  3. `set_task_status` START — for an agent's task this dispatches it.
  4. Follow it with `get_task`. If it pauses in INPUT_REQUIRED, get the answer from the user and
     resume the same task with `submit_task_input` then START. If it waits on an approval, point
     the user to the web app. Report the agent's result back.
- If the user explicitly chooses to do the cloud work under their **own** local cloud credentials,
  that is their call: record it on a task assigned to them and COMPLETE it with what was done.
- A user session has no agent credential, so it gets no cloud credentials: do not assume the
  agent's role or hunt for a credential in files or other places. If the person wants this session
  to be the agent, they restart Claude Code with the agent's credential in its environment.

## Use the MCP tools first

This plugin connects the `stratonext` MCP server. Its tools cover the everyday work surface —
`whoami`, projects, tasks (`list_tasks`, `get_task`, `create_task`, `update_task`,
`set_task_status`, `submit_task_input`), task templates, `list_approvals`, environments, signals,
reports and assets. In agent mode it adds `report_task_progress`,
`request_credential_escalation` and `issue_credentials`. The server's own instructions carry the
operating rules (everything is a task, resume a paused task rather than starting a new one, always
report an outcome, never resolve an approval). Follow them.

If the `stratonext` tools are missing, run the `setup` skill from this plugin.

## When the MCP tools are not enough

Administration and onboarding are deliberately absent from the MCP server: creating
organizations, workspaces or agents, onboarding a cloud account, deployments, memberships, jobs.
For those:

1. Point the user to the web app at https://app.stratonext.com when the action is a human
   decision or administration (approving or rejecting an approval is always done there).
2. Otherwise use the `stratonext` CLI through Bash. It inherits this session's identity (the same
   sign-in, or the same agent credential). Run it as `uvx stratonext@latest <command>` unless
   `stratonext` is already on `PATH`. Before your first CLI command in a session, load the CLI's
   own usage guide with `uvx stratonext@latest --skill` and follow it — it covers JSON output,
   pagination, the `--confirm` flag on destructive commands, and error codes. For a specific
   workflow, export its reference docs with `uvx stratonext@latest --skill-dir <tmp dir>` and read
   the relevant file under `references/`.

## Never

- Approve or reject an approval, including one you requested as an agent.
- Reach for credentials the session's identity does not have.
- Print, log, persist or commit an agent client secret or issued cloud credentials.
