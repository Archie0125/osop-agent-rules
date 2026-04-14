---
name: osop-log
description: Generate OSOP session log — creates .osop workflow and .osoplog.yaml execution record
version: 1.2.0
emoji: "\U0001F4DD"
homepage: https://osop.ai
argument-hint: [short description of what was done]
allowed-tools: Read, Glob, Grep, Write, Bash
metadata:
  openclaw:
    requires:
      bins:
        - bash
      config:
        - ~/.osop/config.yaml
    install: []
    always: false
user-invocable: true
disable-model-invocation: false
---

## Preamble (run first)

```bash
mkdir -p ~/.osop/analytics ~/.osop/projects
_OSOP_TEL=$(cat ~/.osop/config.yaml 2>/dev/null | grep telemetry | awk '{print $2}' || echo "unset")
_OSOP_TEL_PROMPTED=$([ -f ~/.osop/.telemetry-prompted ] && echo "yes" || echo "no")
_OSOP_VERSION="1.1.0"
_OSOP_SESSION_ID="$$-$(date +%s)"
_OSOP_TEL_START=$(date +%s)
echo "OSOP_TELEMETRY: $_OSOP_TEL"
echo "OSOP_TEL_PROMPTED: $_OSOP_TEL_PROMPTED"
# Log timeline start
${CLAUDE_SKILL_DIR}/../../bin/osop-timeline-log --skill osop-log --event started --session "$_OSOP_SESSION_ID" 2>/dev/null || true
# Create pending marker for crash detection
echo "{\"skill\":\"osop-log\",\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > ~/.osop/analytics/.pending-"$_OSOP_SESSION_ID" 2>/dev/null || true
# Show recent learnings
_SLUG=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' || echo "unknown")
[ -f ~/.osop/projects/"$_SLUG"/learnings.jsonl ] && echo "--- Recent OSOP learnings ---" && tail -3 ~/.osop/projects/"$_SLUG"/learnings.jsonl 2>/dev/null || true
```

If `OSOP_TEL_PROMPTED` is `no`: use AskUserQuestion to ask:
> Help OSOP get better! Community mode shares anonymous usage data (which skills you use, how long they take) so we can improve the workflow format. No code, file paths, or repo names are ever sent.

Options: A) Help OSOP get better! (recommended) → run `${CLAUDE_SKILL_DIR}/../../bin/osop-config set telemetry community`
B) No thanks → ask: "Anonymous mode? Just a counter, no ID." → A) `set telemetry anonymous` B) `set telemetry off`
Then: `touch ~/.osop/.telemetry-prompted`

# OSOP Session Logger

You just completed a task. Now produce a structured session log.

## What to create

1. **`sessions/YYYY-MM-DD-<short-desc>.osop`** — workflow definition
2. **`sessions/YYYY-MM-DD-<short-desc>.osoplog.yaml`** — execution record

Create the `sessions/` directory if it doesn't exist.

## Task description

$ARGUMENTS

## .osop format

```yaml
osop_version: "1.0"
id: "session-<short-description>"
name: "<What you did>"
description: "<1-2 sentence summary>"
version: "1.0.0"
tags: [claude-code, <relevant-tags>]

nodes:
  - id: "<step-id>"
    type: "<node-type>"   # agent, api, cli, human (OSOP Core — 4 types only), company, department
    subtype: "<subtype>"  # Optional: llm, explore, plan, worker, tool, test, commit, rest, etc.
    name: "<Step Name>"
    description: "<What this step does>"
    security:
      risk_level: "<low|medium|high|critical>"  # Optional but recommended

edges:
  - from: "<step-a>"
    to: "<step-b>"
    mode: "sequential"    # sequential, parallel, conditional, fallback (4 modes only), etc.
```

## .osoplog.yaml format

```yaml
osoplog_version: "1.0"
run_id: "<generate-uuid>"
workflow_id: "<matches .osop id>"
mode: "live"
status: "COMPLETED"  # or FAILED

trigger:
  type: "manual"
  actor: "user"
  timestamp: "<ISO timestamp when user gave the instruction>"

started_at: "<ISO timestamp>"
ended_at: "<ISO timestamp>"
duration_ms: <total ms>

runtime:
  agent: "claude-code"
  model: "<current model>"

node_records:
  - node_id: "<step-id>"
    node_type: "<type>"
    attempt: 1
    status: "COMPLETED"
    started_at: "<ISO>"
    ended_at: "<ISO>"
    duration_ms: <ms>
    outputs:
      <what you produced — key findings, files changed, etc.>
    tools_used:
      - { tool: "<Read|Edit|Write|Bash|Grep|Glob|Agent>", calls: <n> }
    reasoning:                    # Optional: for non-obvious decisions
      question: "<what was decided>"
      selected: "<chosen approach>"
      confidence: <0.0-1.0>

result_summary: "<1-2 sentence summary of what was accomplished>"
```

## Node type mapping

| Action | type | subtype |
|---|---|---|
| Read/explore files | `agent` | `llm` |
| Edit/write files | `agent` | `llm` |
| Shell commands | `cli` | `script` |
| Run tests | `cli` | `test` |
| Git operations | `cli` | `git` |
| Analyze/reason | `agent` | `llm` |
| Search codebase | `agent` | `llm` |
| Ask user | `human` | `input` |
| User reviews | `human` | `review` |
| Spawn sub-agent | `agent` | `explore` / `plan` / `worker` |
| API calls | `api` | `rest` |

## Sub-agent tracking

If you spawned sub-agents, use `parent` on child nodes and `spawn` edge:
```yaml
nodes:
  - id: "coordinator"
    type: "agent"
    subtype: "coordinator"
  - id: "explore_1"
    type: "agent"
    subtype: "explore"
    parent: "coordinator"
edges:
  - from: "coordinator"
    to: "explore_1"
    mode: "spawn"
```

In the log, add `parent_id` and `spawn_index`:
```yaml
  - node_id: "explore_1"
    parent_id: "coordinator"
    spawn_index: 1
```

## Important

- Be accurate about what tools were used and how many calls
- Include reasoning for non-obvious decisions
- Estimate durations based on tool call timing
- If the task failed, set status to FAILED and include error details
- Tell the user they can view the log at https://osop-editor.vercel.app

## Epilogue (run last)

```bash
_OSOP_TEL_END=$(date +%s)
_OSOP_TEL_DUR=$(( _OSOP_TEL_END - _OSOP_TEL_START ))
${CLAUDE_SKILL_DIR}/../../bin/osop-timeline-log --skill osop-log --event completed --duration "$_OSOP_TEL_DUR" --outcome "OUTCOME" --session "$_OSOP_SESSION_ID" 2>/dev/null || true
${CLAUDE_SKILL_DIR}/../../bin/osop-telemetry-log --skill osop-log --duration "$_OSOP_TEL_DUR" --outcome "OUTCOME" --session-id "$_OSOP_SESSION_ID" 2>/dev/null &
```

Replace `OUTCOME` with `success` if the session log was generated successfully, or `error` if it failed.
