# Terraform

Terraform code for the Azure MCP platform lives here.

## Current Scope

The Terraform implementation creates and manages:

- Azure resource group.
- Azure Storage remote state foundation.
- Azure API Center MCP registry resources.
- Azure API Management Developer gateway.
- Microsoft Learn MCP API in APIM with `apiType = "mcp"`.
- APIM product, subscription, secret named value, and inbound policy.
- APIM policy-managed subscription-key validation and rate limiting.
- API Center environment and deployment metadata for the APIM MCP endpoint.

## Commands

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

See `../../docs/enablement/terraform.md` for the full local setup flow.
