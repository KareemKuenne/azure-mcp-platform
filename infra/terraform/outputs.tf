output "resource_group_name" {
  description = "Name of the platform resource group."
  value       = azurerm_resource_group.platform.name
}

output "resource_group_location" {
  description = "Azure region of the platform resource group."
  value       = azurerm_resource_group.platform.location
}

output "terraform_state_storage_account_name" {
  description = "Storage account that hosts Terraform state."
  value       = azurerm_storage_account.terraform_state.name
}

output "terraform_state_container_name" {
  description = "Blob container that hosts Terraform state."
  value       = azurerm_storage_container.terraform_state.name
}

output "api_center_name" {
  description = "Name of the Azure API Center instance."
  value       = azapi_resource.api_center.name
}

output "api_management_name" {
  description = "Name of the Azure API Management gateway."
  value       = azurerm_api_management.gateway.name
}

output "api_management_gateway_url" {
  description = "Gateway URL of the Azure API Management instance."
  value       = azurerm_api_management.gateway.gateway_url
}

output "microsoft_learn_mcp_gateway_url" {
  description = "Gateway URL for the Microsoft Learn MCP server exposed through API Management."
  value       = "${azurerm_api_management.gateway.gateway_url}/microsoft-learn-mcp/mcp"
}

output "mcp_poc_subscription_primary_key" {
  description = "Primary subscription key for MCP POC testing."
  value       = azurerm_api_management_subscription.mcp_poc.primary_key
  sensitive   = true
}

output "api_center_mcp_registry_url" {
  description = "MCP registry endpoint exposed by Azure API Center."
  value       = "https://${var.api_center_name}.data.${var.location}.azure-apicenter.ms/workspaces/default/v0.1/servers"
}
