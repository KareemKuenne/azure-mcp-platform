# Architecture

This document explains the Azure MCP Platform POC architecture, current implementation, assumptions, and trade-offs.

## Architecture Goals

The POC proves that an enterprise can:

- Register approved MCP servers centrally.
- Govern MCP access through an Azure gateway.
- Let VS Code/GitHub Copilot consume approved MCP tools.
- Apply basic policy enforcement before building custom MCP servers.
- Keep architecture decisions and operational runbooks traceable in Git.

## Architecture Diagrams

Use the diagrams in this order:

1. [System context](diagrams/system-context.md)
2. [Azure resources](diagrams/azure-resources.md)
3. [Runtime flow](diagrams/runtime-flow.md)
4. [Delivery and operations](diagrams/delivery-operations.md)

## Current POC Architecture

The current implementation uses:

- **MCP host**: VS Code with GitHub Copilot Agent mode.
- **MCP registry**: Azure API Center.
- **MCP gateway**: Azure API Management Developer tier.
- **Upstream MCP server**: Microsoft Learn MCP at `https://learn.microsoft.com/api/mcp`.
- **Authentication for POC**: APIM subscription key sent through `Ocp-Apim-Subscription-Key`.
- **Policy enforcement**: APIM inbound policy validates the key and rate-limits calls.
- **Infrastructure as code**: Terraform with AzureRM and AzAPI providers.
- **State management**: Azure Storage remote Terraform state.
- **Documentation**: Markdown in `docs/`, usable as an Obsidian vault.

## Runtime Path

```text
VS Code / GitHub Copilot
  -> APIM endpoint /microsoft-learn-mcp/mcp
  -> APIM inbound policy
  -> Microsoft Learn MCP upstream
```

The VS Code workspace configuration is stored in [.vscode/mcp.json](../.vscode/mcp.json). It defines a Remote HTTP MCP server named `microsoftLearnMcpViaApim`.

The key runtime endpoint is:

```text
https://<apim-name>.azure-api.net/microsoft-learn-mcp/mcp
```

## Registry Model

Azure API Center records the approved Microsoft Learn MCP server with metadata including:

- Owner
- Environment
- Status
- Risk level
- Data classification
- Auth type
- Network exposure
- Tool access
- Business purpose
- Upstream server
- Approved hosts
- Review date
- Documentation URL

The API Center deployment points to the APIM runtime URL. This separates discovery/governance metadata from runtime traffic handling.

## Gateway Model

API Management exposes the Microsoft Learn MCP server at:

```text
/microsoft-learn-mcp/mcp
```

The API is configured in Terraform with:

```hcl
apiType = "mcp"
```

The AzureRM provider does not currently expose a first-class APIM MCP API resource, so Terraform uses `azapi_resource` for that resource shape.

APIM native `subscriptionRequired` is disabled on the MCP API. Instead, an inbound policy checks the `Ocp-Apim-Subscription-Key` header against a secret APIM named value. This avoids APIM returning a built-in `WWW-Authenticate` challenge that previously caused VS Code Remote HTTP MCP to start an OAuth/Dynamic Client Registration flow.

The policy also applies rate limiting to prove basic governance.

## Deployment Model

Local development happens in this repository.

GitHub Actions runs Terraform validation and plan checks, but does not apply infrastructure changes. For this POC, Terraform apply remains manual.

Terraform remote state is stored in:

- Storage account: `<unique-storage-account-name>`
- Container: `tfstate`

## Current Resources

| Purpose | Resource |
| --- | --- |
| Resource group | `rg-<project>-<env>` |
| API Center | `apic-<project>-<env>` |
| API Management | `apim-<project>-<env>` |
| APIM API | `microsoft-learn-mcp` |
| APIM product | `mcp-poc` |
| API Center API | `microsoft-learn-mcp` |
| API Center environment | `apim-dev` |
| API Center deployment | `apim-dev` |

## Verification Status

Completed:

- Azure foundation deployed.
- API Center registry entry created.
- APIM gateway endpoint created.
- APIM policy-managed subscription-key check created.
- APIM rate limit policy created.
- Direct APIM smoke test returned `200`, `text/event-stream`, and `mcp-session-id`.
- VS Code/GitHub Copilot discovered three Microsoft Learn MCP tools through APIM.
- Terraform plan reports `No changes` after apply.

Remaining:

- Capture APIM observability checks.
- Document the target Entra ID/OAuth architecture.

## Trade-Offs

### Subscription Key For POC

Subscription keys are easy to test and good enough to prove gateway enforcement. They are not the target enterprise authentication model.

Target architecture should use Entra ID/OAuth with an MCP-compliant authorization pattern.

### Public Endpoint For POC

The APIM endpoint is public for fast local testing from VS Code. This is acceptable for the POC because access is still controlled by APIM policy.

Target architecture should revisit private networking, VPN, Dev Box, or managed developer environments.

### Developer Tier For APIM

APIM Developer tier is cost-conscious and suitable for non-production validation. It is not production-grade and has no SLA.

Target architecture should evaluate Standard v2, Premium, private networking, and production observability needs.

## Related Documents

- [Main project README](../README.md)
- [Supporting documentation index](README.md)
- [ADR-001](decisions/001-mcp-registry-gateway-poc.md)
- [MCP POC test plan](runbooks/mcp-poc-test-plan.md)
- [VS Code / GitHub Copilot MCP test](runbooks/vscode-copilot-mcp-test.md)
- [Terraform state runbook](runbooks/terraform-state.md)
