---
name: osop-session-logging
description: Generate OSOP session logs after multi-step tasks
---

# OSOP Session Logging

After completing a significant task (multi-step work, not trivial one-liners), produce an **OSOP session log** so there is a structured, portable record of what was done.

1. **Create a `.osop` file** describing the workflow you followed
2. **Create a `.osoplog.yaml` file** recording what you actually did
3. **Tell the user** to open both files at https://osop-editor.vercel.app

## .osop format

```yaml
osop_version: "1.0"
id: "session-<short-description>"
name: "<What you did>"
description: "<1-2 sentence summary>"
version: "1.0.0"
tags: [sweep, <relevant-tags>]
nodes:
  - id: "<step-id>"
    type: "<node-type>"
    subtype: "<subtype>"
    name: "<Step Name>"
    description: "<What this step does>"
edges:
  - from: "<step-a>"
    to: "<step-b>"
    mode: "sequential"
```

## .osoplog.yaml format

```yaml
osoplog_version: "1.0"
run_id: "<uuid>"
workflow_id: "<matches .osop id>"
mode: "live"
status: "COMPLETED"
started_at: "<ISO timestamp>"
ended_at: "<ISO timestamp>"
duration_ms: <total ms>
runtime:
  agent: "sweep"
  model: "<model>"
node_records:
  - node_id: "<step-id>"
    node_type: "<type>"
    status: "COMPLETED"
    duration_ms: <ms>
    tools_used:
      - { tool: "<tool-name>", calls: <n> }
result_summary: "<1-2 sentence summary>"
```

## Where to save

Save to `sessions/` in the project root.

## Sweep integration

Place this file in `.claude/skills/` directory for Sweep AI (JetBrains) to pick up.
