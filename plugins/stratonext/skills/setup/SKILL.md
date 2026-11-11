---
name: setup
description: Set up StratoNext in Claude Code — install uv if missing, detect whether the session runs as a StratoNext agent (agent credential in the environment) or as a user, sign a user in with `stratonext login`, and confirm the StratoNext MCP server is connected. Use when the user runs /stratonext:setup, says they just installed the StratoNext plugin, or a StratoNext tool fails with "Not signed in" or the server shows as failed in /mcp.
---

# Set up StratoNext

The plugin runs the StratoNext MCP server with `uvx stratonext@latest mcp`. It needs **uv** (which
provides `uvx`) and an identity, which is one of:

- **Agent** — the environment Claude Code was started from holds an External agent credential
  (`STRATONEXT_AUTH_API_CLIENT_ID` and `STRATONEXT_AUTH_API_CLIENT_SECRET`). The session then *is*
  that agent: no login, and it gets cloud credentials from StratoNext itself.
- **User** — a person signed in with `stratonext login`. The MCP server can never start a login
  itself, so sign-in is always one terminal command. Cloud work is dispatched to an agent.

Work through the steps in order and stop at the first one that is already satisfied.

## 1. Check uv

Run `uvx --version`.

- If it prints a version, go to step 2.
- If the command is not found, tell the user StratoNext needs uv and offer to install it:
  - macOS / Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`
  - Windows (PowerShell): `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
  - or `brew install uv`

  Ask before running an installer. After installing, the user must restart Claude Code (or open a
  new terminal) so `uvx` is on `PATH` for the MCP server.

## 2. Detect the identity

Check whether the agent credential is present, without printing either value:

```bash
[ -n "$STRATONEXT_AUTH_API_CLIENT_ID" ] && [ -n "$STRATONEXT_AUTH_API_CLIENT_SECRET" ] && echo agent || echo user
```

- **agent**: skip steps 3 and 4 and go to step 5. Never ask for, echo or write down the secret.
- **user**: continue with step 3.
- Only one of the two variables is set: the server falls back to user mode. Tell the user which one
  is missing and that both must be exported in the shell Claude Code is started from (or in its
  `env` settings), then restart Claude Code. Do not set them yourself.

## 3. Check whether the user already has an organization

If the user has never used StratoNext, they first create their organization in the web app at
https://app.stratonext.com, then come back. Ask only if `whoami` in step 5 reports no organization.

## 4. Sign in

The login opens a browser and waits for the callback on `localhost`, so it must run on the user's
own machine. Ask the user to run it themselves by typing this in the Claude Code prompt:

```
! uvx stratonext@latest login
```

(The `!` prefix runs it as a shell command in this session.) Wait for them to confirm the browser
sign-in finished. Credentials are cached in `~/.stratonext/`, so this is a one-time step until the
refresh token expires.

## 5. Verify

Call the `whoami` tool from the `stratonext` MCP server and check `authMode`.

- **`agent`**: setup is done. Summarize which agent this session runs as (from `caller`) and its
  workspace, and tell the user that this session does StratoNext work itself — it tracks the work
  on a task assigned to itself and gets short-lived cloud credentials from StratoNext for tracked
  environments, asking for an escalation when it needs more. Offer a first step such as listing the
  tasks dispatched to it. If `whoami` fails with an authentication error, the credential is wrong
  or revoked: ask the user to check it in the web app, without showing its value.
- **`user`**: if it returns the user and their workspaces, setup is done. Summarize who they are
  signed in as and which workspaces they can use, and that work which must act inside a cloud
  account will be dispatched to a StratoNext agent. Offer a first step such as listing their open
  tasks.
- `authMode` is not what step 2 found: the MCP server started before the variables were set (or
  after they were removed). Ask the user to restart Claude Code from the shell that has the
  intended environment, then try again.
- If it says the user is not signed in, go back to step 4.
- If the tool is not available at all, the server did not start (usually because `uvx` was not on
  `PATH` when Claude Code launched). Ask the user to run `/mcp`, select **stratonext**, and choose
  reconnect — or restart Claude Code — then try `whoami` again.

## Pointing at a non-production environment

The CLI targets production by default. StratoNext staff testing against another environment set
the connection once with `uvx stratonext@latest config set <KEY> <VALUE>` (keys include
`STRATONEXT_API_URL`, `STRATONEXT_AUTH_AUTHORITY`, `STRATONEXT_AUTH_CLIENT_ID`,
`STRATONEXT_AUTH_AUDIENCE`); the MCP server reads the same settings file. Do not suggest this to
customers unless they ask.
