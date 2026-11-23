# StratoNext plugin for Claude Code

Connects Claude Code to the StratoNext Agentic Operations Platform in one install: the StratoNext
MCP server (`stratonext mcp`), two skills, and a session-start hook.

| Component | What it does |
|---|---|
| MCP server `stratonext` | Runs `uvx stratonext@latest mcp`. Projects, tasks, task templates, approvals (read-only), environments, signals, reports, assets. User or machine identity, resolved by the CLI. |
| Skill `stratonext:setup` | Installs uv if missing, detects machine credential (agent or standalone) vs user identity, walks a user through `stratonext login`, verifies with `whoami`. |
| Skill `stratonext:stratonext` | How to work in each identity — as an agent, do the work and get cloud credentials yourself; as a user, dispatch cloud work to an agent — plus when to use the MCP tools and how to fall back to the CLI. |
| Hook `SessionStart` | `hooks/session-start.sh` checks whether the agent credential is in the environment (never printing it) and tells the session which identity it has and how to behave. |

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

### Identity: agent, machine credential or user

The session's identity is decided by the environment Claude Code is started from:

| Environment | Identity | How the session works |
|---|---|---|
| `STRATONEXT_AUTH_API_CLIENT_ID` (`mcc_…`) **and** `STRATONEXT_AUTH_API_CLIENT_SECRET` set | **Machine credential** — a standalone credential created under Settings → Machine credentials | Acts in its workspace with an agent's access, but is never assigned tasks: platform work runs directly, cloud work is dispatched to an agent, and only read-only cloud credentials are issued. |
| `STRATONEXT_AUTH_API_CLIENT_ID` (`agtc_…`) **and** `STRATONEXT_AUTH_API_CLIENT_SECRET` set | **Agent** — the session *is* that registered External agent | Does the work itself: tracks it on a task assigned to itself, gets short-lived AWS credentials from StratoNext (`stratonext credential issue`), and requests an escalation (approved by a human in the web app) when it hits a permission wall. No dispatch. |
| Anything else | **User** — whoever ran `stratonext login` | Platform work directly through the MCP tools; work that must act inside a cloud account is dispatched to a StratoNext agent as a task. No cloud credentials are issued. |

The rule is only whether the credential is present, and which kind it is: if an External agent's
credential is present, the session **is** the agent, interactive or headless, whoever is at the
keyboard. The hook tells the two kinds apart by the client id prefix; the skills confirm it with
`whoami` (`caller.kind`). The MCP server, the CLI, the hook and the
skills all apply it, so they always agree. Put the pair in the environment Claude Code starts from
(a secrets store, a cloud environment's variables, `env` settings), never in a committed file.

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
