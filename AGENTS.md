# Codex Working Conventions

This file captures portable working conventions for Codex and other AI coding agents in this repository.

## Project Intent

This repository is a public, reusable Azure MCP Platform proof of concept.

Keep the repository focused on:

- Azure API Center as MCP registry.
- Azure API Management as MCP gateway.
- VS Code/GitHub Copilot as MCP host.
- Microsoft Learn MCP as initial upstream MCP server.
- Terraform-managed Azure infrastructure.
- Clear public documentation that can help others reproduce the POC.

Do not mix personal laptop enablement into the main architecture narrative. Personal setup and cross-project enablement belong in the separate `codex-cloud-workbench` repository.

## Documentation Style

- Write project documentation in English.
- Use the root `README.md` as the main narrative entry point.
- Keep `README.md` readable from top to bottom with a table of contents.
- Embed the most important diagrams directly in `README.md`.
- Use `docs/` for supporting material: runbooks, ADRs, deeper architecture notes, and diagram research.
- Prefer concise, practical explanations over abstract enterprise language.
- Explain why a decision was made, not only what was changed.

## Diagram Style

- Use Mermaid for diagrams that must render natively in GitHub Markdown.
- Keep Mermaid diagrams small and focused.
- Prefer multiple simple views over one overloaded architecture diagram.
- Use C4-style thinking:
  - Context: people and systems.
  - Container/resource: deployed services and responsibility boundaries.
  - Runtime: sequence of calls.
  - Operations: how changes move through GitHub/Terraform/Azure.
- Consider D2 for more polished generated SVG diagrams.
- Consider LikeC4 or Structurizr if the architecture grows into a larger model with many views.

## Terraform Style

- Keep Terraform under `infra/terraform`.
- Use Terraform for durable Azure resources.
- Use `azapi_resource` when AzureRM does not expose a required Azure preview or newer resource shape.
- Keep `terraform apply` manual for this POC unless explicitly changed.
- Run `terraform fmt`, `terraform validate`, and `terraform plan` before committing infrastructure changes.
- Do not commit Terraform state files, plan files, or secrets.

## Azure Style

- Use predictable names:
  - Resource group: `rg-<project>-<environment>`
  - API Management: `apim-<project>-<environment>`
  - API Center: `apic-<project>-<environment>`
  - Environment: `dev` for this POC
  - Region: `westeurope` for this POC
- Prefer least-privilege access where practical.
- Prefer OIDC over long-lived credentials for GitHub Actions.
- Treat subscription keys as POC-only; target architecture should use Entra ID/OAuth.

## Git Style

- Keep commits focused and descriptive.
- Do not include local Obsidian workspace settings unless explicitly requested.
- Do not commit generated secrets or local environment files.
- Push meaningful completed steps to GitHub.

## Public/Work Boundary

This repository must not contain:

- Employer-internal information.
- Internal architecture screenshots.
- Customer data.
- Non-public endpoint names.
- Credentials or tokens.
- Work-specific confidential naming.

Keep examples generic and reusable.
