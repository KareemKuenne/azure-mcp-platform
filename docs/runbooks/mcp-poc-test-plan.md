# MCP Registry/Gateway POC Test Plan

This test plan validates the end-to-end path from VS Code/GitHub Copilot to a governed MCP server through Azure registry and gateway components.

## Success Criteria

The POC is successful when:

- Microsoft Learn MCP is registered in Azure API Center.
- Azure API Management exposes a governed MCP gateway endpoint.
- API Management requires a subscription key.
- API Management applies at least one rate-limit policy.
- API Center metadata describes owner, risk, auth, exposure, and intended use.
- VS Code/GitHub Copilot can use the MCP server through the gateway.
- Gateway logs show the request path and status.

## Test 1: Upstream MCP Server

Goal: verify that the upstream Microsoft Learn MCP server is reachable before gateway troubleshooting begins.

Target:

- `https://learn.microsoft.com/api/mcp`

Expected result:

- The upstream endpoint responds according to MCP transport expectations.

## Test 1A: Azure POC Foundation

Goal: verify that the registry and gateway resources exist before configuring MCP routing.

Status: completed on 2026-06-13.

Checks:

- API Center instance exists.
- API Management Developer instance exists.
- API Management gateway URL is available.
- Terraform plan reports `No changes` after apply.

Expected result:

- Terraform outputs show `api_center_name`, `api_management_name`, and `api_management_gateway_url`.

Observed result:

- API Center: `apic-<project>-<env>`, provisioning state `Succeeded`.
- API Management: `apim-<project>-<env>`, provisioning state `Succeeded`.
- Gateway URL: `https://<apim-name>.azure-api.net`.
- Terraform plan: `No changes`.

## Test 2: Gateway Without Copilot

Goal: verify API Management routing and subscription-key enforcement before introducing VS Code/GitHub Copilot.

Status: completed on 2026-06-13.

Checks:

- Request with valid subscription key reaches the upstream MCP server.
- Request without subscription key is rejected.
- Request with invalid subscription key is rejected.
- Unknown route returns a controlled error.

Expected result:

- APIM enforces access and forwards valid traffic.

Observed result:

- Request without subscription key returns `401` from the APIM policy without a `WWW-Authenticate` challenge.
- Request with subscription key returns `200`.
- Response content type is `text/event-stream`.
- Response includes `mcp-session-id`.
- Response identifies `Microsoft Learn MCP Server`.

Implementation note:

- Current Terraform implementation exposes the upstream MCP endpoint through an APIM API configured with `apiType = "mcp"` and operations at `/microsoft-learn-mcp/mcp`.
- APIM native `subscriptionRequired` is disabled for this API; an inbound policy checks the `Ocp-Apim-Subscription-Key` header against a secret APIM named value.
- The policy-managed key check avoids APIM's built-in subscription-key `WWW-Authenticate` challenge, which caused VS Code Remote HTTP MCP to enter an OAuth/Dynamic Client Registration flow.
- The direct gateway smoke test returns `200`, `text/event-stream`, `mcp-session-id`, and `Microsoft Learn MCP Server` from the upstream server.

## Test 3: Policy Enforcement

Goal: prove basic governance.

Status: completed on 2026-06-13.

Checks:

- Rate-limit policy is configured.
- Repeated requests over the policy threshold are throttled.
- Error response is understandable.

Expected result:

- APIM returns a throttling response after the configured threshold.

Observed result:

- Rate limit policy is configured at `10` calls per `60` seconds.
- Smoke test returned `429` after repeated successful calls.

## Test 4: Registry Discovery And Metadata

Goal: prove the registry function.

Status: completed for Azure Management API verification on 2026-06-13. Data-plane registry discovery from VS Code/GitHub Copilot remains part of Test 5.

Checks:

- Microsoft Learn MCP server appears in API Center.
- Metadata fields are present.
- Metadata values match ADR-001.
- Discovery path for VS Code/GitHub Copilot is documented.

Expected result:

- A developer can identify the approved MCP endpoint and understand its owner, risk, auth model, and intended use.

Observed result:

- API Center contains API `microsoft-learn-mcp` with kind `mcp` and lifecycle stage `testing`.
- API Center contains environment `apim-dev` for the API Management Developer gateway.
- API Center contains deployment `apim-dev` with runtime URL `https://<apim-name>.azure-api.net/microsoft-learn-mcp/mcp`.
- Metadata includes owner, environment, status, risk, data classification, auth type, network exposure, tool access, business purpose, upstream server, approved hosts, review date, and documentation URL.
- Terraform output exposes the registry URL `https://<api-center-name>.data.<region>.azure-apicenter.ms/workspaces/default/v0.1/servers`.

## Test 5: VS Code / GitHub Copilot End To End

Goal: prove the complete user path.

Status: completed for tool discovery on 2026-06-14 through direct Remote HTTP MCP. Workspace MCP configuration is available in `.vscode/mcp.json`; runbook is `docs/runbooks/vscode-copilot-mcp-test.md`.

Prompt example:

```text
Use the Microsoft Learn MCP server to find official guidance for exposing an existing MCP server through Azure API Management.
```

Expected result:

- Copilot uses the configured MCP endpoint.
- The response is grounded in Microsoft Learn content.
- APIM logs show the corresponding request.

Observed result:

- VS Code started `microsoftLearnMcpViaApim`.
- VS Code output showed `Discovered 3 tools`.
- The discovered tools match the Microsoft Learn MCP tool set: `microsoft_docs_search`, `microsoft_code_sample_search`, and `microsoft_docs_fetch`.

Pre-validation:

- APIM gateway smoke test completed successfully for `initialize` with the `Ocp-Apim-Subscription-Key` header.
- The APIM response used `text/event-stream`, returned an `mcp-session-id`, and identified the upstream as `Microsoft Learn MCP Server`.
- Earlier direct VS Code Remote HTTP MCP attempts entered an OAuth/Dynamic Client Registration path against APIM. The current configuration is the official VS Code Remote HTTP shape with a header input, aligned with the APIM MCP documentation example.

## Test 6: Observability

Goal: verify that gateway operation is visible.

Checks:

- APIM request logs are available.
- Status code is recorded.
- Latency is visible.
- Failed subscription-key attempts are visible.
- Throttling attempts are visible.

Expected result:

- The POC can demonstrate operational governance, not only connectivity.

## Out Of Scope

- Custom MCP server development.
- Private VNet connectivity.
- Entra ID/OAuth for MCP clients.
- Automated `terraform apply` from GitHub Actions.
- Production SLA or multi-region design.
