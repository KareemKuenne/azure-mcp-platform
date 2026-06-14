# Security Policy

## Scope

This repository is a proof of concept and reference implementation. It is not a production service.

## Reporting Security Issues

Please do not open public issues that contain secrets, tokens, tenant IDs, subscription IDs, customer data, or other sensitive information.

For now, report security concerns by opening a GitHub issue without sensitive details and indicate that it is security-related. A private reporting channel can be added later if the project grows.

## Secrets

Never commit:

- APIM subscription keys
- Azure client secrets
- Terraform state files
- Terraform plan files
- Local `.env` files
- Tenant-specific or customer-specific private details

If a key is accidentally exposed, rotate it immediately.

## Production Use

This POC uses simplified controls such as APIM subscription keys and a public gateway endpoint. Production use should revisit:

- Entra ID/OAuth
- Private networking
- Azure Monitor and APIM diagnostics
- Least-privilege Azure RBAC
- Secret management
- Cost controls
