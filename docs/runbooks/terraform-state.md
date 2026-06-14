# Terraform State

Terraform state records the mapping between code and real Azure resources.

## Previous State

The project initially used local state in `infra/terraform/terraform.tfstate`.

This was acceptable for the first single-user bootstrap, but it has limits:

- It only exists on the local machine.
- It is not shared with GitHub Actions.
- It must not be committed to Git.
- Losing it makes future changes harder because Terraform no longer knows what it created.

## Current State

State has been migrated to an Azure Storage backend.

Backend resources:

- Existing platform resource group: `rg-<project>-<env>`.
- Storage account: `<unique-storage-account-name>`.
- Blob container: `tfstate`.
- State blob for the `dev` environment: `dev.terraform.tfstate`.
- Azure RBAC/access for the local user through Azure CLI authentication.

## Backend Configuration

The backend block lives in `infra/terraform/backend.tf`. Backend settings are supplied at init time because Terraform backend blocks cannot use normal input variables.

```bash
terraform init -migrate-state \
  -backend-config="resource_group_name=rg-<project>-<env>" \
  -backend-config="storage_account_name=<unique-storage-account-name>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev.terraform.tfstate" \
  -backend-config="use_azuread_auth=true"
```

## Migration Steps

1. Create the storage account and container while Terraform still uses local state.
2. Add an AzureRM backend block to `infra/terraform`.
3. Run `terraform init -migrate-state` with backend configuration.
4. Verify that Terraform can read outputs from remote state.

## Verification

Completed on 2026-06-13:

- `terraform init -migrate-state -force-copy` succeeded.
- `terraform state list` shows the resource group, storage account, and state container.
- `terraform plan` reports `No changes`.
- The `tfstate` container has public access disabled.

## Follow-Up

GitHub Actions access is configured through GitHub OIDC.

The workflow authenticates to Azure, initializes the Azure Storage backend, and runs `terraform plan`. It does not run `terraform apply`.
