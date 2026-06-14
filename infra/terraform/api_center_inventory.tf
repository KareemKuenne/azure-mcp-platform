locals {
  api_center_default_workspace_id = "${azapi_resource.api_center.id}/workspaces/default"
  api_center_workspace_path       = "/workspaces/default"
  microsoft_learn_mcp_gateway_url = "${azurerm_api_management.gateway.gateway_url}/microsoft-learn-mcp/mcp"
}

resource "azapi_resource" "api_center_environment_apim_dev" {
  type      = "Microsoft.ApiCenter/services/workspaces/environments@2024-06-01-preview"
  name      = "apim-dev"
  parent_id = local.api_center_default_workspace_id

  body = {
    properties = {
      title       = "APIM Developer Gateway"
      description = "Azure API Management Developer tier gateway for the Azure MCP Platform POC."
      kind        = "development"
      server = {
        type = "Azure API Management"
        managementPortalUri = [
          "https://portal.azure.com/#@/resource${azurerm_api_management.gateway.id}"
        ]
      }
      onboarding = {
        developerPortalUri = [
          azurerm_api_management.gateway.developer_portal_url
        ]
        instructions = "Use an approved APIM subscription key to access governed MCP endpoints."
      }
      customProperties = {
        networkExposure = "public-poc"
      }
    }
  }
}

resource "azapi_resource" "api_center_microsoft_learn_mcp" {
  type      = "Microsoft.ApiCenter/services/workspaces/apis@2024-06-01-preview"
  name      = "microsoft-learn-mcp"
  parent_id = local.api_center_default_workspace_id

  body = {
    properties = {
      title       = "Microsoft Learn MCP"
      summary     = "Governed Microsoft Learn MCP access through Azure API Management."
      description = "Microsoft Learn MCP server exposed through the Azure MCP Platform API Management gateway for POC validation."
      kind        = "mcp"
      contacts = [
        {
          name  = "Platform Team"
          email = var.api_management_publisher_email
        }
      ]
      externalDocumentation = [
        {
          title       = "Microsoft Learn"
          description = "Official Microsoft Learn documentation."
          url         = "https://learn.microsoft.com/"
        },
        {
          title       = "MCP through APIM"
          description = "Azure API Management documentation for exposing existing MCP servers."
          url         = "https://learn.microsoft.com/en-us/azure/api-management/expose-existing-mcp-server"
        }
      ]
      customProperties = {
        owner              = "platform-team"
        environment        = "dev"
        status             = "approved"
        riskLevel          = "low"
        dataClassification = "public"
        authType           = "subscription-key"
        networkExposure    = "public-poc"
        toolAccess         = "read-only"
        businessPurpose    = "Microsoft Learn documentation lookup through governed MCP access"
        upstreamServer     = "https://learn.microsoft.com/api/mcp"
        approvedForHosts   = "VS Code, GitHub Copilot"
        lastReviewed       = "2026-06-13"
        documentationUrl   = "https://learn.microsoft.com/"
      }
    }
  }
}

resource "azapi_resource" "api_center_microsoft_learn_mcp_version" {
  type      = "Microsoft.ApiCenter/services/workspaces/apis/versions@2024-06-01-preview"
  name      = "version-1"
  parent_id = azapi_resource.api_center_microsoft_learn_mcp.id

  body = {
    properties = {
      title          = "v1"
      lifecycleStage = "testing"
    }
  }
}

resource "azapi_resource" "api_center_microsoft_learn_mcp_deployment" {
  type                      = "Microsoft.ApiCenter/services/workspaces/apis/deployments@2024-06-01-preview"
  name                      = "apim-dev"
  parent_id                 = azapi_resource.api_center_microsoft_learn_mcp.id
  schema_validation_enabled = false

  body = {
    properties = {
      title         = "APIM Developer Gateway"
      description   = "POC deployment of Microsoft Learn MCP through Azure API Management."
      environmentId = "${local.api_center_workspace_path}/environments/${azapi_resource.api_center_environment_apim_dev.name}"
      versionId     = "${local.api_center_workspace_path}/apis/${azapi_resource.api_center_microsoft_learn_mcp.name}/versions/${azapi_resource.api_center_microsoft_learn_mcp_version.name}"
      state         = "active"
      server = {
        runtimeUri = [
          local.microsoft_learn_mcp_gateway_url
        ]
      }
      customProperties = {
        authType        = "subscription-key"
        networkExposure = "public-poc"
      }
    }
  }
}
