# StratoNext plugins for Claude Code

The official [Claude Code](https://claude.com/claude-code) plugin marketplace for
[StratoNext](https://www.stratonext.com), the Agentic Operations Platform.

## Install

```text
/plugin marketplace add stratonext/claude-plugins
/plugin install stratonext@stratonext
/stratonext:setup
```

You need [uv](https://docs.astral.sh/uv/) and a StratoNext organization — create one at
https://app.stratonext.com.

## Plugins

| Plugin | What it does |
|---|---|
| [`stratonext`](plugins/stratonext/) | Connects Claude Code to StratoNext: projects, tasks, approvals, environments, reports and assets, through the StratoNext MCP server. |
