# Azure Resources

This diagram shows the Azure resources deployed for the POC and their relationships.

```mermaid
flowchart TB
  subgraph rg[Resource Group<br/>rg-<project>-<env>]
    st[Storage Account<br/><unique-storage-account-name>]
    container[Blob Container<br/>tfstate]
    apic[API Center<br/>apic-<project>-<env>]
    apicApi[API Center API<br/>microsoft-learn-mcp<br/>kind: mcp]
    apicEnv[API Center Environment<br/>apim-dev]
    apicDeployment[API Center Deployment<br/>apim-dev]
    apim[API Management<br/>apim-<project>-<env><br/>Developer tier]
    product[APIM Product<br/>mcp-poc]
    api[APIM API<br/>microsoft-learn-mcp<br/>apiType: mcp]
    subscription[APIM Subscription<br/>MCP POC test subscription]
    namedValue[APIM Named Value<br/>MCP-POC-gateway-key<br/>secret]
    policy[APIM API Policy<br/>key validation + rate limit]
  end

  st --> container
  apic --> apicApi
  apic --> apicEnv
  apicApi --> apicDeployment
  apicEnv --> apicDeployment
  apicDeployment -.->|runtime URL| api

  apim --> product
  apim --> api
  product --> subscription
  product --> api
  subscription -->|primary key stored as secret| namedValue
  api --> policy
  namedValue --> policy
```

## Key Points

- Terraform state is remote in Azure Storage.
- API Center records the approved MCP server and deployment metadata.
- API Management exposes the runtime MCP endpoint.
- APIM policy validates the subscription key and applies rate limiting.
- The APIM named value keeps the policy comparison secret-backed.
