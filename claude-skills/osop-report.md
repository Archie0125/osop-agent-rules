---
name: osop-report
description: Generate a standalone HTML report from .osop and .osoplog files using osop view
version: 2.0.0
homepage: https://osop.ai
argument-hint: <file.sop or file.osop> [--lang zh-TW]
allowed-tools: Read, Bash, Write, Glob
metadata:
  openclaw:
    requires:
      bins:
        - bash
    install: []
    always: false
user-invocable: true
---

# OSOP Report Generator

Convert workflow definitions and execution logs into a browsable HTML report.

## Arguments

$ARGUMENTS

If no arguments provided, look for the most recent `.sop` file in `sessions/`.

## Steps

1. **Find the files** — identify the .sop file (or create a temporary one referencing the .osop)

2. **Generate the HTML report** using `osop view`:
   ```bash
   # From a .sop file (recommended — supports multiple workflows)
   osop view <file.sop> -o <output.html>
   
   # With Traditional Chinese
   osop view <file.sop> -o <output.html> --lang zh-TW
   ```

   If `osop` is not in PATH, use `python -m osop.cli view`.

3. **If only .osop + .osoplog provided** (no .sop), create a temporary .sop:
   ```yaml
   sop_version: "1.0"
   id: "temp-report"
   name: "<workflow name>"
   sections:
     - name: "Workflow"
       workflows:
         - ref: "./<file.osop.yaml>"
           title: "<workflow name>"
   ```
   Then run `osop view` on it.

4. **Tell the user** the output file path so they can open it in a browser.

## Features

The generated HTML includes:
- Visual workflow display with node type badges and status colors
- Side-by-side .osop definition and .osoplog execution view
- Multi-run tabs when multiple .osoplog files exist
- Raw YAML view toggle
- Copy-to-clipboard for YAML content
- Light theme matching osop.ai website style
- Zero external dependencies — single self-contained HTML file
