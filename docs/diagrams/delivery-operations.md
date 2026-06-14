# Delivery And Operations

This diagram shows how local development, GitHub, Terraform, and Azure operations fit together.

```mermaid
flowchart LR
  local[Local Workspace<br/>Codex + VS Code]
  git[Local Git Repository]
  github[GitHub Repository<br/>main branch]
  actions[GitHub Actions<br/>Terraform validate/plan]
  tf[Terraform CLI<br/>manual apply]
  state[Azure Storage<br/>remote Terraform state]
  azure[Azure Resources<br/>API Center + APIM]
  docs[Docs / Obsidian Vault<br/>docs/]

  local -->|edit code, docs, Terraform| git
  local --> docs
  git -->|commit + push| github
  github --> actions
  actions -->|plan only via OIDC| azure
  tf -->|read/write state| state
  tf -->|manual apply| azure
  azure -->|runtime test| local
```

## Key Points

- Local work is committed and pushed to GitHub.
- GitHub Actions validates and plans Terraform, but does not apply production changes.
- Terraform apply is manual for the POC.
- Remote state lives in Azure Storage.
- `docs/` works as both repository documentation and an Obsidian vault.
