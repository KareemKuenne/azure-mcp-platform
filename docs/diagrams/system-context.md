# System Context

This diagram shows the main actors and systems in the MCP registry/gateway POC.

```mermaid
flowchart LR
  user[Developer]
  vscode[VS Code<br/>GitHub Copilot Agent Mode]
  repo[GitHub Repository<br/>azure-mcp-platform]
  apic[Azure API Center<br/>MCP Registry]
  apim[Azure API Management<br/>MCP Gateway]
  learn[Microsoft Learn MCP Server<br/>https://learn.microsoft.com/api/mcp]

  user -->|opens workspace| vscode
  user -->|reads and updates docs/code| repo
  repo -->|workspace config<br/>.vscode/mcp.json| vscode
  repo -->|Terraform-managed metadata| apic
  repo -->|Terraform-managed gateway config| apim

  vscode -->|MCP over HTTP<br/>Ocp-Apim-Subscription-Key| apim
  apim -->|forwards valid MCP traffic| learn

  apic -.->|documents approved server,<br/>owner, auth, risk, deployment URL| apim
```

## Key Points

- VS Code/GitHub Copilot is the MCP host.
- API Management is the runtime gateway for MCP traffic.
- API Center is the registry and governance catalog.
- Microsoft Learn MCP is the first upstream MCP server.
- Terraform keeps the Azure platform configuration reproducible.
