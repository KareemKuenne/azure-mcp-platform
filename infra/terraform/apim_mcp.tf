resource "azurerm_api_management_product" "mcp_poc" {
  product_id            = "mcp-poc"
  api_management_name   = azurerm_api_management.gateway.name
  resource_group_name   = azurerm_resource_group.platform.name
  display_name          = "MCP POC"
  description           = "Governed MCP server access for the Azure MCP Platform proof of concept."
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azapi_resource" "microsoft_learn_mcp_api" {
  type      = "Microsoft.ApiManagement/service/apis@2024-05-01"
  name      = "microsoft-learn-mcp"
  parent_id = azurerm_api_management.gateway.id

  body = {
    properties = {
      apiType              = "mcp"
      displayName          = "Microsoft Learn MCP"
      description          = "Governed proxy for the Microsoft Learn MCP server."
      path                 = "microsoft-learn-mcp"
      protocols            = ["https"]
      serviceUrl           = "https://learn.microsoft.com/api"
      subscriptionRequired = false
      subscriptionKeyParameterNames = {
        header = "Ocp-Apim-Subscription-Key"
        query  = "subscription-key"
      }
    }
  }
}

resource "azurerm_api_management_api_operation" "microsoft_learn_mcp_post" {
  operation_id        = "mcp-post"
  api_name            = azapi_resource.microsoft_learn_mcp_api.name
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.platform.name
  display_name        = "MCP message"
  method              = "POST"
  url_template        = "/mcp"
  description         = "Forwards Streamable HTTP MCP client messages to Microsoft Learn MCP."

  request {
    representation {
      content_type = "application/json"
    }
  }

  response {
    status_code = 200
    description = "MCP response stream."
  }

  depends_on = [azapi_resource.microsoft_learn_mcp_api]
}

resource "azurerm_api_management_api_operation" "microsoft_learn_mcp_get" {
  operation_id        = "mcp-get"
  api_name            = azapi_resource.microsoft_learn_mcp_api.name
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.platform.name
  display_name        = "MCP stream"
  method              = "GET"
  url_template        = "/mcp"
  description         = "Forwards Streamable HTTP MCP stream requests to Microsoft Learn MCP."

  response {
    status_code = 200
    description = "MCP stream response."
  }

  depends_on = [azapi_resource.microsoft_learn_mcp_api]
}

resource "azurerm_api_management_product_api" "microsoft_learn_mcp" {
  product_id          = azurerm_api_management_product.mcp_poc.product_id
  api_name            = azapi_resource.microsoft_learn_mcp_api.name
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.platform.name

  depends_on = [azapi_resource.microsoft_learn_mcp_api]
}

resource "azurerm_api_management_named_value" "mcp_poc_gateway_key" {
  name                = "mcp-poc-gateway-key"
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.platform.name
  display_name        = "MCP-POC-gateway-key"
  secret              = true
  value               = azurerm_api_management_subscription.mcp_poc.primary_key
}

resource "azurerm_api_management_api_policy" "microsoft_learn_mcp" {
  api_name            = azapi_resource.microsoft_learn_mcp_api.name
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.platform.name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <choose>
      <when condition="@(context.Request.Headers.GetValueOrDefault(&quot;Ocp-Apim-Subscription-Key&quot;, &quot;&quot;) != &quot;{{MCP-POC-gateway-key}}&quot;)">
        <return-response>
          <set-status code="401" reason="Unauthorized" />
          <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
          </set-header>
          <set-body>{"statusCode":401,"message":"Access denied due to invalid or missing MCP gateway subscription key."}</set-body>
        </return-response>
      </when>
    </choose>
    <rate-limit-by-key calls="10" renewal-period="60" counter-key="@(context.Request.Headers.GetValueOrDefault(&quot;Ocp-Apim-Subscription-Key&quot;, context.Request.IpAddress))" remaining-calls-variable-name="remainingCalls" />
    <trace source="Azure MCP Platform" severity="information">
      <message>Microsoft Learn MCP request</message>
      <metadata name="agent-id" value="@(context.Request.Headers.GetValueOrDefault(&quot;agent-id&quot;, &quot;n/a&quot;))" />
    </trace>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML

  depends_on = [
    azapi_resource.microsoft_learn_mcp_api,
    azurerm_api_management_named_value.mcp_poc_gateway_key
  ]
}

resource "azurerm_api_management_subscription" "mcp_poc" {
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.platform.name
  product_id          = azurerm_api_management_product.mcp_poc.id
  display_name        = "MCP POC test subscription"
  state               = "active"
  allow_tracing       = true
}
