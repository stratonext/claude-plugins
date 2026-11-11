---
name: stratonext
description: Work with the StratoNext platform — projects, tasks, task templates, approvals, environments, signals, reports and assets. Use whenever the user asks to look up, create or update anything in StratoNext, check work assigned to them, hand work to a StratoNext agent, or follow up on a task or approval.
---

# Working with StratoNext

StratoNext is an Agentic Operations Platform: trusted AI agents do production work alongside
human teams, under workspace roles, approvals and an audit trail.

## Use the MCP tools first

This plugin connects the `stratonext` MCP server. Its tools cover the everyday work surface —
`whoami`, projects, tasks (`list_tasks`, `get_task`, `create_task`, `update_task`,
`set_task_status`, `submit_task_input`), task templates, `list_approvals`, environments, signals,
reports and assets. The server's own instructions carry the operating rules (everything is a task,
resume a paused task rather than starting a new one, always report an outcome, never resolve an
approval). Follow them.

If a tool answers that the user is not signed in, or the `stratonext` tools are missing, run the
`setup` skill from this plugin (`/stratonext:setup`).

## When the MCP tools are not enough

Administration and onboarding are deliberately absent from the MCP server: creating
organizations, workspaces or agents, onboarding a cloud account, deployments, memberships, jobs.
For those:

1. Point the user to the web app at https://app.stratonext.com when the action is a human
   decision or administration (approving or rejecting an approval is always done there).
2. Otherwise use the `stratonext` CLI through Bash, which shares the MCP server's sign-in. Run it
   as `uvx stratonext@latest <command>` unless `stratonext` is already on `PATH`. Before your first
   CLI command in a session, load the CLI's own usage guide with
   `uvx stratonext@latest --skill` and follow it — it covers JSON output, pagination, the
   `--confirm` flag on destructive commands, and error codes. For a specific workflow, export its
   reference docs with `uvx stratonext@latest --skill-dir <tmp dir>` and read the relevant file
   under `references/`.

## Never

- Approve or reject an approval on the user's behalf.
- Assume a cloud role, mint credentials, or look for another way around a permission the user
  lacks. Delegate the work to a StratoNext agent with a task instead, and read back its result.
