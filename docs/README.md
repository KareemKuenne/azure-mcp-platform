# Azure MCP Platform Supporting Documentation

This folder contains supporting artifacts for the Azure MCP Platform proof of concept.

The root [README.md](../README.md) is the main public project documentation. Start there first. It contains the project overview, architecture, deployment path, test path, security model, cost model, decisions, limitations, and references.

## Table of Contents

- [Purpose](#purpose)
- [Supporting Artifacts](#supporting-artifacts)
- [Where To Verify Things](#where-to-verify-things)
- [Documentation Model](#documentation-model)
- [References And Diagram Variants](#references-and-diagram-variants)
- [Next Steps](#next-steps)

## Purpose

The root README explains the project. This folder exists for details that should not interrupt the main reading flow.

## Supporting Artifacts

| Path | Purpose |
| --- | --- |
| [../README.md](../README.md) | Main documentation and public project entry point |
| [Home.md](Home.md) | Obsidian vault home |
| [architecture.md](architecture.md) | Additional architecture notes and trade-offs |
| [diagrams/](diagrams/README.md) | Mermaid diagram source files used by the README and appendices |
| [diagram-variants/](diagram-variants/README.md) | Alternative diagram tooling outputs, including D2, PlantUML, and LikeC4 |
| [decisions/](decisions/README.md) | Architecture Decision Records |
| [runbooks/](runbooks/README.md) | Operational test and setup procedures |
| [references.md](references.md) | Consolidated source references |

## Where To Verify Things

Use these files to understand or verify the POC:

| Question | File |
| --- | --- |
| What is the project and architecture? | [Root README](../README.md) |
| Why did we choose API Center and APIM? | [ADR-001](decisions/001-mcp-registry-gateway-poc.md) |
| How do I test VS Code/GitHub Copilot end to end? | [VS Code MCP runbook](runbooks/vscode-copilot-mcp-test.md) |
| What are the POC success criteria? | [MCP POC test plan](runbooks/mcp-poc-test-plan.md) |
| How is Terraform state handled? | [Terraform state runbook](runbooks/terraform-state.md) |
| What does Terraform deploy? | [infra/terraform](../infra/terraform/README.md) |

## Documentation Model

This project uses a README-first documentation model:

- Keep [README.md](../README.md) as the main document people can read from top to bottom.
- Keep supporting docs for details that are operational, historical, or too specific for the main flow.
- Link from the README to runbooks, ADRs, references, and diagram source files.

## References And Diagram Variants

References are collected in [references.md](references.md).

Diagram tooling research is captured in [diagram-tooling.md](diagram-tooling.md).

Alternative diagram sources and rendered D2 output are available in [diagram-variants](diagram-variants/README.md).

## Next Steps

Near-term:

1. Add APIM observability checks.
2. Start ADR-002 for the target OAuth/Entra ID architecture.
3. Review diagram variants and choose the preferred style for future public documentation.

Later:

- Replace subscription-key auth with Entra ID/OAuth for enterprise use.
- Evaluate private networking for APIM and client access.
- Add a second MCP server to prove registry discovery and governance at more than one entry.
- Consider automated smoke tests for APIM MCP initialization and tool discovery.
