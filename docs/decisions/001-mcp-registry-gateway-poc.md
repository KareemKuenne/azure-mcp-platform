# ADR-001: Use Azure API Center and API Management for the MCP Registry/Gateway POC

## Status

Accepted

## Date

2026-06-13

## Context

The project needs to prove an enterprise-oriented MCP platform pattern before implementing custom MCP servers.

The proof of concept should show that:

- MCP servers can be centrally registered and described.
- A governed gateway can sit between MCP hosts and MCP servers.
- VS Code with GitHub Copilot can consume an approved MCP server.
- Policy enforcement can be applied without building a custom MCP server first.

The initial MCP host is VS Code/GitHub Copilot. The initial MCP server is the Microsoft Learn MCP server.

Official documentation references:

- MCP architecture: https://modelcontextprotocol.io/docs/learn/architecture
- VS Code MCP servers: https://code.visualstudio.com/docs/agent-customization/mcp-servers
- Azure API Management for existing MCP servers: https://learn.microsoft.com/en-us/azure/api-management/expose-existing-mcp-server
- Azure API Center MCP registration and discovery: https://learn.microsoft.com/en-us/azure/api-center/register-discover-mcp-server
- Azure API Center metadata: https://learn.microsoft.com/en-us/azure/api-center/set-metadata-properties
- Azure API Management pricing and tiers: https://azure.microsoft.com/en-us/pricing/details/api-management/

## Decision

Use this POC architecture:

- Registry: Azure API Center.
- Gateway: Azure API Management Developer tier.
- Initial MCP server: Microsoft Learn MCP server at `https://learn.microsoft.com/api/mcp`.
- Initial MCP host: VS Code with GitHub Copilot.
- Authentication: API Management subscription key checked by APIM policy for the POC.
- Tool governance level: medium.
- Network model: public POC endpoint with gateway controls; private VNet is deferred.
- Deployment model: Terraform-managed Azure resources, with GitHub Actions running `terraform plan` only.

## Alternatives Considered

### Build A Custom MCP Server First

This would prove server implementation details, but it would slow down registry and gateway learning. It is deferred until the platform pattern is proven.

### Use Azure Container Apps As The First Gateway

Container Apps is a strong option for custom MCP servers or a custom gateway later. For this POC, API Management better matches the governance goal because it provides API policies, subscription keys, rate limits, and gateway observability.

### Use Private VNet Integration From The Start

Private networking better matches an enterprise target architecture. It is deferred because local VS Code/GitHub Copilot needs a network path into the VNet, such as VPN, Dev Box, or a jump environment. The POC prioritizes fast end-to-end validation.

### Use Entra ID/OAuth For The First Authentication Model

OAuth is a better enterprise authentication model, but subscription keys are simpler for proving the gateway pattern. OAuth is a follow-up once the end-to-end path works.

### Use API Management Premium Or Standard v2

Premium is production-capable but too expensive for this POC. Standard v2 is also more expensive than needed and does not match the immediate evaluation goal. Developer tier is non-production and lower cost, which fits the POC.

## Governance Metadata

API Center entries should include these metadata fields:

- `owner`
- `environment`
- `status`
- `riskLevel`
- `dataClassification`
- `authType`
- `networkExposure`
- `toolAccess`
- `businessPurpose`
- `upstreamServer`
- `approvedForHosts`
- `lastReviewed`
- `documentationUrl`

Initial values for Microsoft Learn MCP:

- `owner`: platform-team
- `environment`: dev
- `status`: approved
- `riskLevel`: low
- `dataClassification`: public
- `authType`: subscription-key
- `networkExposure`: public-poc
- `toolAccess`: read-only
- `businessPurpose`: Microsoft Learn documentation lookup through governed MCP access
- `upstreamServer`: https://learn.microsoft.com/api/mcp
- `approvedForHosts`: VS Code, GitHub Copilot
- `lastReviewed`: 2026-06-13
- `documentationUrl`: https://learn.microsoft.com/

## Tool Control Policy

Use medium tool governance for the POC:

- Only registered MCP servers are approved.
- Only approved hosts are documented.
- Read-only MCP usage is preferred.
- API Management requires a subscription key through an inbound policy.
- API Management applies rate limiting.
- API Management logs requests for validation and troubleshooting.
- Registry metadata records owner, risk, auth, exposure, and intended use.

## Consequences

Positive:

- Fastest path to a real end-to-end MCP registry/gateway proof.
- Uses Microsoft-managed services aligned with enterprise API governance.
- Avoids early custom MCP server implementation.
- Keeps `terraform apply` manual while CI performs real Azure-backed plans.

Trade-offs:

- Public POC endpoint is less enterprise-secure than private VNet.
- Subscription keys are weaker than Entra ID/OAuth.
- API Management Developer tier is not production-grade and has no SLA.
- APIM introduces ongoing cost while provisioned.

Implementation note:

- The current automated implementation uses an API Management API configured with `apiType = "mcp"` to proxy Microsoft Learn MCP traffic.
- Terraform manages the APIM MCP gateway through `azapi_resource` because the AzureRM provider does not yet expose a first-class MCP API resource.
- This proves the POC gateway controls: subscription key, routing, rate limiting, and testable MCP traffic through APIM.
- The VS Code Remote HTTP MCP client treated APIM's built-in subscription-key challenge as an OAuth/Dynamic Client Registration path. To keep the POC on subscription-key auth while avoiding that challenge, APIM's native `subscriptionRequired` setting is disabled for the MCP API and an inbound policy validates the `Ocp-Apim-Subscription-Key` header against a secret named value.

## Follow-Ups

- Implement API Center and API Management with Terraform. Completed on 2026-06-13.
- Register Microsoft Learn MCP server. Completed on 2026-06-13.
- Add API Management policies for subscription key enforcement and rate limiting. Completed on 2026-06-13.
- Configure APIM gateway API as MCP API type. Completed on 2026-06-14.
- Add observability checks.
- Test VS Code/GitHub Copilot end to end.
- Revisit private networking after the POC succeeds.
- Revisit OAuth/Entra ID after subscription-key gateway validation.
