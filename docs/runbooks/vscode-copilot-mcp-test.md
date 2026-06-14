# VS Code / GitHub Copilot MCP Test

This runbook validates that VS Code with GitHub Copilot can use the Microsoft Learn MCP server through the Azure MCP Platform API Management gateway.

## Prerequisites

- VS Code with GitHub Copilot enabled.
- This workspace opened in VS Code.
- APIM subscription key for the `mcp-poc` subscription.
- MCP gateway endpoint: `https://<apim-name>.azure-api.net/microsoft-learn-mcp/mcp`.

To retrieve the APIM subscription key locally:

```sh
cd infra/terraform
terraform output -raw mcp_poc_subscription_primary_key
```

## Configuration

The workspace MCP configuration lives in `.vscode/mcp.json`.

It defines one remote HTTP MCP server:

- Server name: `microsoftLearnMcpViaApim`
- URL: `https://<apim-name>.azure-api.net/microsoft-learn-mcp/mcp`
- Auth header: `Ocp-Apim-Subscription-Key`

The subscription key is not stored in Git. VS Code prompts for it the first time the server starts and stores it in the local secure input store.

Implementation note: APIM native `subscriptionRequired` is disabled for this API because its built-in challenge led VS Code Remote HTTP MCP into an OAuth/Dynamic Client Registration path. The POC instead validates the same `Ocp-Apim-Subscription-Key` header through an APIM inbound policy against a secret APIM named value. This keeps the POC on direct Remote HTTP MCP while still proving APIM gateway policy enforcement.

## Manual Test

1. Open this repository in VS Code.
2. Open the Command Palette with `Shift` + `Command` + `P`.
3. Run `MCP: List Servers`.
4. Select `microsoftLearnMcpViaApim`.
5. Choose `Start Server`.
6. When prompted, enter the APIM subscription key.
7. Confirm trust for the server configuration if prompted.
8. Open GitHub Copilot Chat in Agent mode.
9. Check the available tools and confirm the Microsoft Learn MCP tools are listed.
10. Send this prompt:

```text
Use the Microsoft Learn MCP server to find official guidance for exposing an existing MCP server through Azure API Management.
```

## Expected Result

- VS Code starts the remote HTTP MCP server configuration successfully.
- Microsoft Learn MCP tools are available in Copilot Chat.
- Copilot can answer using Microsoft Learn content through the APIM gateway.
- APIM receives the request on `/microsoft-learn-mcp/mcp`.

## Troubleshooting

- If the server does not start, run `MCP: List Servers`, select `microsoftLearnMcpViaApim`, and choose `Show Output`.
- If VS Code shows `Dynamic Client Registration not supported`, stop the server, run `Developer: Reload Window`, run `MCP: Reset Cached Tools`, and start `microsoftLearnMcpViaApim` again. If it still happens, capture the MCP output; that means VS Code is still treating the APIM endpoint as an OAuth-capable protected resource even though the workspace config uses only headers.
- If APIM returns `401`, restart the server and re-enter only the 32-character APIM key.
- If tools are missing after a configuration change, run `MCP: Reset Cached Tools`.
- If trust blocks execution, run `MCP: Reset Trust` and start the server again.
