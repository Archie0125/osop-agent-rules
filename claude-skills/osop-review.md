---
name: osop-review
description: Review a .osop or .osoplog file for security risks, permission gaps, and missing safeguards
version: 2.0.0
homepage: https://osop.ai
argument-hint: <path-to-osop-or-osoplog-file>
allowed-tools: Read, Glob, Grep, Bash
metadata:
  openclaw:
    requires:
      bins:
        - bash
    install: []
    always: false
user-invocable: true
---

# OSOP Workflow Reviewer

Review a workflow or execution log for risks and issues.

## Target file

$ARGUMENTS

## What to do

1. **Validate first**:
   ```bash
   osop validate <file>
   ```

2. **Read the file** and analyze for risks:

   **For .osop workflows, check:**
   - `cli` nodes with destructive commands (`rm -rf`, `kubectl delete`, `terraform destroy`, `DROP TABLE`)
   - Hardcoded secrets (strings starting with `sk-`, `ghp_`, `xoxb-`, API keys)
   - `agent` nodes without cost constraints (unbounded LLM usage)
   - `api` nodes calling external services without error handling
   - Missing `fallback` edges on critical-path nodes
   - Missing `human` approval before destructive `cli` steps

   **For .osoplog execution logs, also check:**
   - Which tools were actually used and how many calls
   - Whether any nodes failed and why
   - Total execution time — was it reasonable?
   - Sub-agent hierarchy — was spawning appropriate?

3. **Compute risk score** (0-100):

   | Node Type | Base Weight |
   |-----------|------------|
   | `cli` | 2.0 |
   | `api` | 1.5 |
   | `agent` | 1.5 |
   | `human` | 0.5 |

   Mitigations: human approval before risky step = -50%, fallback edge = -20%

4. **Present findings**:
   ```
   Risk Score: XX/100 — VERDICT

   | Severity | Finding | Node | Suggestion |
   |----------|---------|------|------------|
   | HIGH | rm -rf in deploy step | deploy | Add human approval gate |
   ```

   Verdicts: SAFE (0-25), CAUTION (26-50), WARNING (51-75), DANGER (76-100)

5. **Summarize**: Is this workflow safe to run? What should be changed?

## OSOP Core types

4 node types: `agent`, `api`, `cli`, `human`
4 edge modes: `sequential`, `parallel`, `conditional`, `fallback`
