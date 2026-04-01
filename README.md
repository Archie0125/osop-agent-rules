# OSOP Agent Rules

[![OSOP Compatible](https://img.shields.io/badge/OSOP-compatible-blue)](https://osop.ai)

Drop-in OSOP session logging for **every major AI coding agent**. One install gives your AI agent the ability to produce structured workflow records (`.osop` + `.osoplog.yaml`) after every significant task.

## Supported Platforms

| Platform | File | Install Method |
|----------|------|---------------|
| **Cursor** | `.cursor/rules/osop-session-logging.mdc` | Auto / Manual |
| **OpenAI Codex** | `AGENTS.md` | Auto / Manual |
| **Windsurf** | `.windsurf/rules/osop-session-logging.md` | Auto / Manual |
| **Continue.dev** | `.continue/rules/osop-session-logging.yaml` | Auto / Manual |
| **Aider** | `CONVENTIONS.md` | Auto / Manual |
| **Cline** | `.clinerules/osop-session-logging.md` | Auto / Manual |
| **Roo Code** | `.roo/rules/osop-session-logging.md` | Auto / Manual |
| **Devin** | `playbooks/osop-session-logging.md` | Auto / Manual |
| **Claude Code** | `CLAUDE.md` | [Plugin](https://github.com/Archie0125/osop-skill) |
| **OpenClaw** | ClawHub skill | `clawhub install osop` |
| **GitHub Copilot** | MCP server | [osop-mcp](https://github.com/Archie0125/osop-mcp) |

## Quick Install

### Auto-detect (recommended)

```bash
git clone https://github.com/Archie0125/osop-agent-rules.git
cd osop-agent-rules
./install.sh
```

The installer detects which AI tools you have and installs the right files.

### Install for all platforms

```bash
./install.sh --all
```

### Install for specific platforms

```bash
./install.sh --cursor --aider --codex
```

### List detected platforms

```bash
./install.sh --list
```

## Manual Install

Copy the file for your platform into your project:

### Cursor

```bash
mkdir -p .cursor/rules
cp cursor/osop-session-logging.mdc .cursor/rules/
```

### OpenAI Codex

```bash
cp codex/AGENTS.md .
```

### Windsurf

```bash
mkdir -p .windsurf/rules
cp windsurf/osop-session-logging.md .windsurf/rules/
```

### Continue.dev

```bash
mkdir -p .continue/rules
cp continue-dev/osop-rules.yaml .continue/rules/osop-session-logging.yaml
```

### Aider

```bash
cp aider/CONVENTIONS.md .
```

Or add to existing `.aider.conf.yml`:

```yaml
read:
  - path/to/osop-agent-rules/aider/CONVENTIONS.md
```

### Cline

```bash
mkdir -p .clinerules
cp cline/osop-session-logging.md .clinerules/
```

### Roo Code

```bash
mkdir -p .roo/rules
cp roo-code/osop-session-logging.md .roo/rules/
```

### Devin

```bash
mkdir -p playbooks
cp devin/osop-session-logging.md playbooks/
```

### Claude Code

Use the native plugin:

```bash
claude /install-plugin https://github.com/Archie0125/osop-skill
```

### OpenClaw

```bash
clawhub install osop
clawhub install osop-log
clawhub install osop-report
clawhub install osop-review
clawhub install osop-optimize
```

### GitHub Copilot

Use the MCP server — see [copilot/README.md](copilot/README.md).

## What You Get

After your AI agent completes a multi-step task, it produces:

**`sessions/2026-04-01-fix-auth-bug.osop`** — workflow definition
```yaml
osop_version: "1.0"
id: session-fix-auth-bug
name: "Fix Authentication Bug"
nodes:
  - id: explore
    type: agent
    subtype: explore
    name: "Search Auth Code"
  - id: fix
    type: mcp
    name: "Write Fix"
edges:
  - from: explore
    to: fix
```

**`sessions/2026-04-01-fix-auth-bug.osoplog.yaml`** — execution record
```yaml
osoplog_version: "1.0"
status: COMPLETED
duration_ms: 930000
node_records:
  - node_id: explore
    status: COMPLETED
    tools_used:
      - { tool: Grep, calls: 5 }
      - { tool: Read, calls: 4 }
```

View them at **https://osop-editor.vercel.app** or generate HTML reports.

## Structure

```
osop-agent-rules/
├── CORE-INSTRUCTIONS.md     # Platform-agnostic source content
├── install.sh               # Universal installer
├── cursor/                  # Cursor .mdc rule
├── codex/                   # OpenAI Codex AGENTS.md
├── windsurf/                # Windsurf rule
├── continue-dev/            # Continue.dev YAML rule
├── aider/                   # Aider CONVENTIONS.md
├── cline/                   # Cline rule
├── roo-code/                # Roo Code rule
├── devin/                   # Devin playbook
└── copilot/                 # Copilot MCP integration guide
```

## Links

- **Spec:** https://github.com/Archie0125/osop-spec
- **Visual Editor:** https://osop-editor.vercel.app
- **Examples:** https://github.com/Archie0125/osop-examples
- **Website:** https://osop.ai
- **Claude Code Plugin:** https://github.com/Archie0125/osop-skill
- **OpenClaw Skills:** `clawhub search osop`

## License

Apache-2.0
