# StratoNext plugin for Claude Code

Connects Claude Code to the StratoNext Agentic Operations Platform in one install: the StratoNext
MCP server (`stratonext mcp`) plus two skills.

| Component | What it does |
|---|---|
| MCP server `stratonext` | Runs `uvx stratonext@latest mcp`. Projects, tasks, task templates, approvals (read-only), environments, signals, reports, assets. User or machine identity, resolved by the CLI. |
| Skill `stratonext:setup` | Installs uv if missing, walks through `stratonext login`, verifies with `whoami`. |
| Skill `stratonext:stratonext` | When to use the MCP tools, and how to fall back to the CLI (and its bundled `--skill` guide) for what the server deliberately leaves out. |

## Install

Requires [uv](https://docs.astral.sh/uv/) and a StratoNext organization (create one at
https://app.stratonext.com).

```text
/plugin marketplace add stratonext/claude-plugins
/plugin install stratonext@stratonext
/stratonext:setup
```

`/stratonext:setup` signs you in (`! uvx stratonext@latest login`, one browser round-trip) and
checks the connection. After that, just ask Claude about your StratoNext work.

From a shell instead:

```bash
claude plugin marketplace add stratonext/claude-plugins
claude plugin install stratonext@stratonext
```

### Machine identity

To run the server as a registered External agent instead of as yourself, export
`STRATONEXT_AUTH_API_CLIENT_ID` and `STRATONEXT_AUTH_API_CLIENT_SECRET` in the environment you
start Claude Code from. The server picks machine mode at startup and exposes the agent work loop
(`report_task_progress`, `request_credential_escalation`, `issue_credentials`).

## How it stays current

- The MCP server is always the latest published CLI (`stratonext@latest`), so new tools ship with
  a normal CLI release — no plugin update needed.
- The plugin itself is pinned by `version` in `.claude-plugin/plugin.json`. Bump it whenever a
  skill or the manifest changes, or installed users won't receive the update.

## Develop

```bash
claude plugin validate plugins/stratonext
claude plugin validate .                      # the marketplace at the repo root
claude --plugin-dir plugins/stratonext   # try it without installing
```
