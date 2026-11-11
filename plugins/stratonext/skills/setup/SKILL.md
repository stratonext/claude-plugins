---
name: setup
description: Set up StratoNext in Claude Code — install uv if missing, sign in with `stratonext login`, and confirm the StratoNext MCP server is connected. Use when the user runs /stratonext:setup, says they just installed the StratoNext plugin, or a StratoNext tool fails with "Not signed in" or the server shows as failed in /mcp.
---

# Set up StratoNext

The plugin runs the StratoNext MCP server with `uvx stratonext@latest mcp`. It needs two things on
the user's machine: **uv** (which provides `uvx`) and a **signed-in StratoNext session**. The MCP
server can never start a login itself, so sign-in is always one terminal command.

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

## 2. Check whether the user already has an organization

If the user has never used StratoNext, they first create their organization in the web app at
https://app.stratonext.com, then come back. Ask only if `whoami` in step 4 reports no organization.

## 3. Sign in

The login opens a browser and waits for the callback on `localhost`, so it must run on the user's
own machine. Ask the user to run it themselves by typing this in the Claude Code prompt:

```
! uvx stratonext@latest login
```

(The `!` prefix runs it as a shell command in this session.) Wait for them to confirm the browser
sign-in finished. Credentials are cached in `~/.stratonext/`, so this is a one-time step until the
refresh token expires.

## 4. Verify

Call the `whoami` tool from the `stratonext` MCP server.

- If it returns the user and their workspaces, setup is done. Summarize who they are signed in as
  and which workspaces they can use, then offer a first step such as listing their open tasks.
- If it says the user is not signed in, go back to step 3.
- If the tool is not available at all, the server did not start (usually because `uvx` was not on
  `PATH` when Claude Code launched). Ask the user to run `/mcp`, select **stratonext**, and choose
  reconnect — or restart Claude Code — then try `whoami` again.

## Pointing at a non-production environment

The CLI targets production by default. StratoNext staff testing against another environment set
the connection once with `uvx stratonext@latest config set <KEY> <VALUE>` (keys include
`STRATONEXT_API_URL`, `STRATONEXT_AUTH_AUTHORITY`, `STRATONEXT_AUTH_CLIENT_ID`,
`STRATONEXT_AUTH_AUDIENCE`); the MCP server reads the same settings file. Do not suggest this to
customers unless they ask.
