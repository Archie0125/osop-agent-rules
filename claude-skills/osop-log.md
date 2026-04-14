---
name: osop-log
description: Generate OSOP session log — creates .osop workflow definition and .osoplog.yaml execution record
version: 2.0.0
homepage: https://osop.ai
argument-hint: [short description of what was done]
allowed-tools: Read, Glob, Grep, Write, Bash
metadata:
  openclaw:
    requires:
      bins:
        - bash
    install: []
    always: false
user-invocable: true
---

# OSOP Session Logger

You just completed a task. Now produce a structured session log.

## Task description

$ARGUMENTS

## What to create

1. **`sessions/YYYY-MM-DD-<short-desc>.osop.yaml`** — workflow definition
2. **`sessions/YYYY-MM-DD-<short-desc>.osoplog.yaml`** — execution record

Create the `sessions/` directory if it doesn't exist.

## .osop format

```yaml
osop_version: "1.0"
id: "session-<short-description>"
name: "<What you did>"
description: "<1-2 sentence summary>"
tags: [claude-code, <relevant-tags>]

nodes:
  - id: "<step-id>"
    type: "<agent|api|cli|human>"
    name: "<Step Name>"
    description: "<What this step does>"

edges:
  - from: "<step-a>"
    to: "<step-b>"
    mode: "sequential"    # sequential | parallel | conditional | fallback
```

## .osoplog.yaml format

```yaml
osoplog_version: "1.0"
run_id: "<generate-uuid>"
workflow_id: "<matches .osop id>"
status: "COMPLETED"  # or FAILED

started_at: "<ISO timestamp>"
ended_at: "<ISO timestamp>"
duration_ms: <total ms>

runtime:
  agent: "claude-code"
  model: "<current model>"

node_records:
  - node_id: "<step-id>"
    node_type: "<type>"
    status: "COMPLETED"
    started_at: "<ISO>"
    ended_at: "<ISO>"
    duration_ms: <ms>
    outputs:
      <what you produced>
    tools_used:
      - { tool: "<tool-name>", calls: <n> }

result_summary: "<1-2 sentence summary of what was accomplished>"
```

## Node type mapping (OSOP Core — 4 types only)

| Claude Code Action | type |
|---|---|
| Read/explore/search/edit/write files | `agent` |
| Analyze/reason/plan/generate code | `agent` |
| Spawn sub-agent | `agent` |
| Run shell commands / tests / git | `cli` |
| API calls (web fetch) | `api` |
| Ask user / user reviews | `human` |

## Sub-agent tracking

If you spawned sub-agents, use `parent` on child nodes:
```yaml
nodes:
  - id: "coordinator"
    type: "agent"
    name: "Coordinate Work"
  - id: "explore_1"
    type: "agent"
    name: "Explore Codebase"
    parent: "coordinator"
edges:
  - from: "coordinator"
    to: "explore_1"
    mode: "parallel"
```

## Important

- Be accurate about what tools were used and how many calls
- Estimate durations based on tool call timing
- If the task failed, set status to FAILED and include error details
- Use OSOP Core types only: agent, api, cli, human
- Tell the user they can view the log at https://osop-editor.vercel.app
