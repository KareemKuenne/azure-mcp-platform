variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used by the AzureRM provider."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Short project name used for resource naming."
  type        = string
  default     = "azure-mcp-platform"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region for platform resources."
  type        = string
  default     = "westeurope"
}

variable "state_storage_account_name" {
  description = "Globally unique Azure Storage account name used for Terraform state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.state_storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase letters or numbers."
  }
}

variable "api_center_name" {
  description = "Name of the Azure API Center instance used as the MCP registry."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,90}$", var.api_center_name))
    error_message = "API Center name must be 3-90 characters using letters, numbers, or hyphens."
  }
}

variable "api_management_name" {
  description = "Globally unique name of the Azure API Management instance used as the MCP gateway."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,50}$", var.api_management_name))
    error_message = "API Management name must be 3-50 characters using letters, numbers, or hyphens."
  }
}

variable "api_management_publisher_name" {
  description = "Publisher name shown in Azure API Management."
  type        = string
  default     = "Azure MCP Platform"
}

variable "api_management_publisher_email" {
  description = "Publisher email shown in Azure API Management."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
