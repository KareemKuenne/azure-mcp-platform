# Runtime Flow

This sequence shows what happens when VS Code starts the MCP server and discovers tools through APIM.

```mermaid
sequenceDiagram
  autonumber
  actor Developer
  participant VSCode as VS Code / GitHub Copilot
  participant APIM as Azure API Management
  participant Policy as APIM Inbound Policy
  participant Learn as Microsoft Learn MCP

  Developer->>VSCode: Start microsoftLearnMcpViaApim
  VSCode->>Developer: Prompt for APIM subscription key
  Developer->>VSCode: Enter key locally
  VSCode->>APIM: POST /microsoft-learn-mcp/mcp<br/>initialize<br/>Ocp-Apim-Subscription-Key
  APIM->>Policy: Validate key against secret named value
  Policy->>Policy: Apply rate limit
  Policy-->>APIM: Allow request
  APIM->>Learn: Forward MCP initialize
  Learn-->>APIM: text/event-stream<br/>mcp-session-id<br/>serverInfo
  APIM-->>VSCode: MCP initialize result
  VSCode->>APIM: tools/list
  APIM->>Policy: Validate key and rate limit
  APIM->>Learn: Forward tools/list
  Learn-->>APIM: Microsoft Learn tools
  APIM-->>VSCode: Tool list
  VSCode-->>Developer: Discovered 3 tools
```

## Key Points

- The APIM subscription key is entered locally in VS Code and is not committed to Git.
- APIM native `subscriptionRequired` is disabled for this API.
- The inbound policy performs the POC key check to avoid triggering an OAuth challenge.
- Successful startup is visible in VS Code output as `Discovered 3 tools`.
