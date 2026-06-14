# Azure MCP Platform Documentation

This is the supporting documentation index for the Azure MCP Platform proof of concept.

The root [README.md](../README.md) is the main public project narrative.

## Table of Contents

- [Purpose](#purpose)
- [What We Built](#what-we-built)
- [Current Architecture](#current-architecture)
- [How The End-To-End Flow Works](#how-the-end-to-end-flow-works)
- [Azure Resources](#azure-resources)
- [Repository Map](#repository-map)
- [Where To Verify Things](#where-to-verify-things)
- [Documentation Model](#documentation-model)
- [References And Diagram Variants](#references-and-diagram-variants)
- [Next Steps](#next-steps)

## Purpose

The project proves an enterprise-oriented pattern for governing Model Context Protocol (MCP) servers on Azure.

The POC answers four practical questions:

1. Can we register approved MCP servers centrally?
2. Can we put a governed Azure gateway in front of an MCP server?
3. Can VS Code with GitHub Copilot consume that MCP server through the gateway?
4. Can we apply basic policy controls before building custom MCP servers?

The answer is now yes for the first POC path.

## What We Built

The current POC contains:

- GitHub repository for code, Terraform, decisions, runbooks, and docs.
- Azure resource group for the development environment.
- Azure Storage remote backend for Terraform state.
- GitHub OIDC identity for Azure-backed Terraform plans.
- Azure API Center as the MCP registry.
- Azure API Management Developer tier as the MCP gateway.
- Microsoft Learn MCP exposed through API Management.
- API Management policy that validates an `Ocp-Apim-Subscription-Key` header.
- API Management rate limiting for governed MCP calls.
- VS Code workspace MCP configuration for GitHub Copilot.
- Runbooks for Terraform state and the MCP end-to-end test.

The successful end-to-end path is:

```text
VS Code / GitHub Copilot
  -> Azure API Management
  -> Microsoft Learn MCP Server
```

VS Code discovered three tools from Microsoft Learn MCP through APIM:

- `microsoft_docs_search`
- `microsoft_code_sample_search`
- `microsoft_docs_fetch`

## Current Architecture

Use these diagrams for different levels of architectural understanding:

- [System context](diagrams/system-context.md) explains who talks to what.
- [Azure resources](diagrams/azure-resources.md) shows the deployed Azure components.
- [Runtime flow](diagrams/runtime-flow.md) shows request handling during MCP initialization and tool discovery.
- [Delivery and operations](diagrams/delivery-operations.md) shows how local work, GitHub, Terraform, and Azure fit together.

The detailed architecture narrative is in [architecture.md](architecture.md).

## How The End-To-End Flow Works

1. The repository contains `.vscode/mcp.json`.
2. VS Code reads that workspace MCP configuration.
3. The MCP server entry uses Remote HTTP:

   ```json
   {
     "type": "http",
     "url": "https://<apim-name>.azure-api.net/microsoft-learn-mcp/mcp",
     "headers": {
       "Ocp-Apim-Subscription-Key": "${input:apim-subscription-key-remote-http-v1}"
     }
   }
   ```

4. VS Code prompts locally for the APIM subscription key.
5. VS Code sends MCP protocol messages to APIM with the key in the header.
6. APIM validates the key through an inbound policy.
7. APIM applies rate limiting.
8. APIM forwards valid MCP traffic to `https://learn.microsoft.com/api/mcp`.
9. Microsoft Learn MCP returns the tool list.
10. GitHub Copilot can use those tools in Agent mode.

## Azure Resources

Current development resources:

| Purpose | Resource |
| --- | --- |
| Resource group | `rg-<project>-<env>` |
| Terraform state storage account | `<unique-storage-account-name>` |
| Terraform state container | `tfstate` |
| API Center registry | `apic-<project>-<env>` |
| API Management gateway | `apim-<project>-<env>` |
| APIM MCP API | `microsoft-learn-mcp` |
| APIM product | `mcp-poc` |
| API Center MCP API | `microsoft-learn-mcp` |
| API Center environment | `apim-dev` |
| API Center deployment | `apim-dev` |

Important endpoints:

| Purpose | Endpoint |
| --- | --- |
| APIM gateway | `https://<apim-name>.azure-api.net` |
| Microsoft Learn MCP through APIM | `https://<apim-name>.azure-api.net/microsoft-learn-mcp/mcp` |
| Upstream Microsoft Learn MCP | `https://learn.microsoft.com/api/mcp` |
| API Center MCP registry | `https://<api-center-name>.data.<region>.azure-apicenter.ms/workspaces/default/v0.1/servers` |

## Repository Map

| Path | Purpose |
| --- | --- |
| [README.md](../README.md) | Repository-level entry point |
| [docs/README.md](README.md) | Documentation entry point |
| [docs/Home.md](Home.md) | Obsidian vault home |
| [docs/architecture.md](architecture.md) | Architecture narrative |
| [docs/diagrams/](diagrams/README.md) | Architecture sketches |
| [docs/decisions/](decisions/README.md) | Architecture Decision Records |
| [docs/runbooks/](runbooks/README.md) | Operational test and setup procedures |
| [infra/terraform/](../infra/terraform/README.md) | Terraform implementation |
| [.vscode/mcp.json](../.vscode/mcp.json) | VS Code MCP workspace configuration |

## Where To Verify Things

Use these files to understand or verify the POC:

| Question | File |
| --- | --- |
| What is the architecture? | [architecture.md](architecture.md) |
| Why did we choose API Center and APIM? | [ADR-001](decisions/001-mcp-registry-gateway-poc.md) |
| How do I test VS Code/GitHub Copilot end to end? | [VS Code MCP runbook](runbooks/vscode-copilot-mcp-test.md) |
| What are the POC success criteria? | [MCP POC test plan](runbooks/mcp-poc-test-plan.md) |
| How is Terraform state handled? | [Terraform state runbook](runbooks/terraform-state.md) |
| What does Terraform deploy? | [infra/terraform](../infra/terraform/README.md) |

## Documentation Model

Good documentation for this project should have five layers:

1. **README-first overview**: the root README is the main narrative.
2. **Architecture**: diagrams plus a narrative of components, flows, boundaries, and trade-offs.
3. **Decisions**: ADRs that record important choices and alternatives.
4. **Runbooks**: step-by-step operational procedures for humans.
5. **Implementation references**: Terraform, VS Code config, and CI files as source of truth.

This project now uses a README-first model:

- Keep [README.md](../README.md) as the main document people can read from top to bottom.
- Keep supporting docs for details that would make the README too long or too operational.
- Link from the README to runbooks, ADRs, and deeper architecture notes.

## References And Diagram Variants

References are collected in [references.md](references.md).

Diagram tooling research is captured in [diagram-tooling.md](diagram-tooling.md).

Alternative diagram sources and rendered D2 output are available in [diagram-variants](diagram-variants/README.md).

## Next Steps

Near-term:

1. Run a Copilot chat prompt that invokes one of the discovered Microsoft Learn MCP tools.
2. Add APIM observability checks.
3. Rotate any APIM subscription key that was exposed during local testing.
4. Start ADR-002 for the target OAuth/Entra ID architecture.

Later:

- Replace subscription-key auth with Entra ID/OAuth for enterprise use.
- Evaluate private networking for APIM and client access.
- Add a second MCP server to prove registry discovery and governance at more than one entry.
- Consider automated smoke tests for APIM MCP initialization and tool discovery.
