resource "azapi_resource" "api_center" {
  type      = "Microsoft.ApiCenter/services@2024-06-01-preview"
  name      = var.api_center_name
  parent_id = azurerm_resource_group.platform.id
  location  = azurerm_resource_group.platform.location
  tags      = local.common_tags

  body = {
    properties = {}
  }
}

resource "azurerm_api_management" "gateway" {
  name                = var.api_management_name
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  publisher_name      = var.api_management_publisher_name
  publisher_email     = var.api_management_publisher_email
  sku_name            = "Developer_1"

  public_network_access_enabled = true

  protocols {
    http2_enabled = true
  }

  tags = local.common_tags
}
