---
name: osop-report
description: Convert .osop and .osoplog.yaml into standalone HTML report with dark mode and expandable nodes
version: 1.2.0
emoji: "\U0001F4CA"
homepage: https://osop.ai
argument-hint: <file.osop> [file.osoplog.yaml]
allowed-tools: Read, Bash, Write
metadata:
  openclaw:
    requires:
      anyBins:
        - python3
        - python
      config:
        - ~/.osop/config.yaml
    install:
      - kind: uv
        package: pyyaml
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
${CLAUDE_SKILL_DIR}/../../bin/osop-timeline-log --skill osop-report --event started --session "$_OSOP_SESSION_ID" 2>/dev/null || true
echo "{\"skill\":\"osop-report\",\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > ~/.osop/analytics/.pending-"$_OSOP_SESSION_ID" 2>/dev/null || true
_SLUG=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' || echo "unknown")
[ -f ~/.osop/projects/"$_SLUG"/learnings.jsonl ] && echo "--- Recent OSOP learnings ---" && tail -3 ~/.osop/projects/"$_SLUG"/learnings.jsonl 2>/dev/null || true
```

If `OSOP_TEL_PROMPTED` is `no`: use AskUserQuestion — same prompt as osop-log preamble.

# OSOP Report Generator

Convert workflow definition and/or execution log into a self-contained HTML report.

## Arguments

$ARGUMENTS

If no arguments provided, look for the most recent files in `sessions/` directory.

## Steps

1. **Find the files** — read the .osop file (first argument). If a .osoplog.yaml is also provided (second argument), read that too.

2. **Generate the HTML report** by running:
   ```bash
   python ${CLAUDE_SKILL_DIR}/../../scripts/osop-report.py <file.osop> [file.osoplog.yaml] -o <output.html>
   ```
   
   If Python/PyYAML is not available, generate the HTML inline using this structure:
   - Read both YAML files
   - Create a self-contained HTML with inline CSS
   - Each node becomes an expandable `<details>` element
   - Color-code by node type (orange=human, purple=agent, blue=api/cli)
   - Show status badges, duration bars, tool usage, AI metadata, reasoning blocks
   - Include dark mode via `prefers-color-scheme`

3. **Save the HTML** next to the source file with `-report.html` suffix.

4. **Tell the user** the file path so they can open it in a browser.

## Output format

The HTML report includes:
- Header: workflow name, status badge, duration, cost, node count
- Error banner: any failed nodes listed prominently
- Node list: expandable cards with type badge, duration bar, inputs/outputs, AI metadata, tool usage, reasoning
- Dark mode responsive, <15KB, zero external dependencies

## Epilogue (run last)

```bash
_OSOP_TEL_END=$(date +%s)
_OSOP_TEL_DUR=$(( _OSOP_TEL_END - _OSOP_TEL_START ))
${CLAUDE_SKILL_DIR}/../../bin/osop-timeline-log --skill osop-report --event completed --duration "$_OSOP_TEL_DUR" --outcome "OUTCOME" --session "$_OSOP_SESSION_ID" 2>/dev/null || true
${CLAUDE_SKILL_DIR}/../../bin/osop-telemetry-log --skill osop-report --duration "$_OSOP_TEL_DUR" --outcome "OUTCOME" --session-id "$_OSOP_SESSION_ID" 2>/dev/null &
```

Replace `OUTCOME` with `success` or `error`. If the report generation fails, log a learning:
```bash
${CLAUDE_SKILL_DIR}/../../bin/osop-learnings-log '{"skill":"osop-report","type":"pitfall","key":"ERROR_KEY","insight":"WHAT_WENT_WRONG","confidence":8,"source":"observed"}' 2>/dev/null || true
```
