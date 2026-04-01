# OSOP + GitHub Copilot

GitHub Copilot integrates with OSOP through the **MCP (Model Context Protocol)** server.

## Setup

Add the OSOP MCP server to your Copilot configuration:

```json
{
  "mcpServers": {
    "osop": {
      "command": "python",
      "args": ["-m", "osop_mcp"],
      "env": {
        "OSOP_MCP_URL": "http://localhost:8080"
      }
    }
  }
}
```

## Available MCP Tools

Once connected, Copilot can use:

| Tool | Description |
|------|-------------|
| `osop.validate` | Validate .osop workflows against the schema |
| `osop.risk_assess` | Security & risk analysis (0-100 score) |
| `osop.run` | Execute workflows (dry-run supported) |
| `osop.render` | Generate Mermaid/ASCII diagrams |
| `osop.test` | Run workflow test cases |
| `osop.optimize` | Suggest improvements from execution history |
| `osop.report` | Generate HTML execution reports |
| `osop.import` | Convert GitHub Actions/BPMN/Airflow to OSOP |
| `osop.export` | Convert OSOP to external formats |

## Install the MCP Server

```bash
pip install osop-mcp
```

Or via Docker:

```bash
docker run -p 8080:8080 ghcr.io/archie0125/osop-mcp
```

## Links

- **MCP Server:** https://github.com/Archie0125/osop-mcp
- **Spec:** https://github.com/Archie0125/osop-spec
- **Visual Editor:** https://osop-editor.vercel.app
- **Website:** https://osop.ai
