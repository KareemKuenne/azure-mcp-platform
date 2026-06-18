# MCP Host/Server Compatibility Assessment

This document captures the initial compatibility assessment for extending the Azure MCP Platform POC beyond Microsoft Learn MCP.

The goal is to distinguish clearly between:

- What is confirmed by official documentation.
- What is inferred from official documentation but still needs validation.
- What is currently an assumption or gap.
- How each assumption should be tested in a future proof of concept.

## Evidence Levels

| Level | Meaning | Use In This Document |
| --- | --- | --- |
| Confirmed | Explicitly stated in official vendor or platform documentation | Strong basis for planning |
| Officially indicated | Supported by official documentation, but not for the exact enterprise gateway path | Good candidate, needs POC validation |
| Vendor support signal | Stated in an official vendor-controlled support or community forum, but not in formal product documentation | Treat as a strong risk or clarification signal, then validate with the vendor or a POC |
| Inferred | Reasonable technical conclusion from official docs and architecture constraints | Treat as an assumption |
| Not confirmed | No official source found during this research pass | Do not build on it without further validation |

## Research Method

This assessment uses the following research checks for each host/server candidate:

1. Confirm whether an official MCP server or connector exists.
2. Confirm the documented transport and runtime model: remote HTTP, SSE, local stdio, desktop extension, or vendor-managed connector.
3. Check whether the target host is explicitly supported.
4. Check whether the authentication model supports arbitrary clients, third-party OAuth apps, Dynamic Client Registration, API keys, or only vendor-supported clients.
5. Check whether an enterprise gateway/proxy is explicitly supported, explicitly blocked, or only inferred.
6. Separate formal documentation from vendor support/forum signals and from technical assumptions.

The most important lesson from the Figma review is that "remote MCP server exists" is not enough. For enterprise gateway planning, the compatibility question is:

> Can this remote MCP server be accessed through an enterprise-controlled gateway by a client identity that the vendor accepts?

## Platform Baseline

### Azure API Management

Confirmed:

- API Management can expose and govern existing remote MCP servers.
- External MCP servers must conform to MCP `2025-06-18` or later.
- External MCP servers can use Streamable HTTP or SSE transports.
- API Management can apply policies to MCP servers.
- API Management can expose REST APIs as MCP servers.

Important limitation:

- API Management currently supports MCP tools for REST APIs exposed as MCP servers, but not all MCP capabilities such as prompts.
- Policy logic must not buffer MCP streaming responses by reading `context.Response.Body`.

Source:

- https://learn.microsoft.com/en-us/azure/api-management/expose-existing-mcp-server
- https://learn.microsoft.com/en-us/azure/api-management/export-rest-mcp-server

### Azure API Center

Confirmed:

- API Center can register remote MCP servers.
- API Center can register local MCP servers by package metadata.
- API Center can store MCP server inventory, remotes, packages, versions, use cases, and documentation links.

Implication:

- API Center can remain the registry for all three integration patterns:
  - Remote MCP through APIM.
  - Local MCP package inventory.
  - Custom MCP wrapper or APIM-exposed REST API.

Source:

- https://learn.microsoft.com/en-us/azure/api-center/register-discover-mcp-server

### VS Code / GitHub Copilot

Confirmed:

- VS Code supports MCP servers through workspace or user configuration.
- VS Code supports remote HTTP MCP servers and local stdio MCP servers.
- VS Code can share workspace MCP configuration through `.vscode/mcp.json`.
- VS Code has trust prompts, server enable/disable controls, troubleshooting output, and central management through GitHub policies.
- VS Code supports sandboxing for local stdio MCP servers on macOS and Linux.

Implication:

- GitHub Copilot in VS Code is the strongest current host candidate for:
  - Remote APIM-gated MCP servers.
  - Local stdio MCP servers.
  - Local governance experiments.

Source:

- https://code.visualstudio.com/docs/agent-customization/mcp-servers

### Microsoft 365 Copilot Chat

Confirmed:

- Microsoft 365 Copilot can be extended with agents, connectors, Work IQ API, and Copilot APIs.
- Microsoft 365 Copilot connectors support two models:
  - Synced connectors that ingest content into Microsoft Graph.
  - Federated connectors that retrieve content in real time by using MCP without indexing data into Microsoft Graph.

Important interpretation:

- The official Microsoft 365 Copilot Chat path is not simply "point Copilot Chat directly at any MCP URL."
- For enterprise use, the relevant extension surface appears to be Copilot extensibility through agents and Copilot connectors, especially federated connectors for MCP-based real-time retrieval.

Source:

- https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview
- https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview-copilot-connector

### Claude Desktop

Confirmed:

- Claude Desktop supports local MCP servers through desktop extensions.
- Claude supports remote MCP through custom connectors.
- For remote connectors, Claude connects from Anthropic cloud infrastructure, so the remote MCP server must be reachable from Anthropic's IP ranges.
- Local MCP servers configured in Claude Desktop are separate from remote connectors and use the local machine/network.

Implication:

- Chrome DevTools MCP fits best as a local Claude Desktop or local developer tooling use case.
- Remote MCP through APIM is possible in principle for Claude custom connectors, but APIM/network/auth compatibility must be tested separately.

Source:

- https://support.claude.com/en/articles/10949351-getting-started-with-local-mcp-servers-on-claude-desktop
- https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp

## Compatibility Matrix

| Candidate | Target Host | Official MCP Availability | Transport / Runtime | Gateway Fit | Registry Fit | Evidence Level | Recommended Pattern | POC Question |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Supermetrics | Microsoft 365 Copilot Chat | Supermetrics documents AI chats and a Supermetrics MCP server | Supermetrics-managed AI chat integration; MCP server for custom integrations | Not confirmed for APIM in front of the Supermetrics MCP server | Yes, if remote endpoint/package details are available | Officially indicated | A or vendor-native Copilot integration | Can Supermetrics MCP be routed through APIM and still work with Microsoft 365 Copilot extensibility, or should the vendor-native Copilot integration be used instead? |
| Contentsquare | Microsoft 365 Copilot Chat | No official Contentsquare MCP server found in this research pass | Official REST APIs and Data Connect exist | APIM REST-to-MCP is plausible, but not confirmed | Yes, as custom wrapper or REST-to-MCP asset | Inferred | C | Can Contentsquare REST APIs be exposed as MCP tools through APIM or a custom wrapper, and can Microsoft 365 Copilot consume them through a connector/agent? |
| Firecrawl | GitHub Copilot / VS Code | Firecrawl documents an MCP server | Remote hosted URL, local `npx`, Streamable HTTP support | Strong fit for APIM remote MCP gateway | Strong fit as remote MCP registry entry | Confirmed for MCP, inferred for APIM fronting | A | Can APIM proxy Firecrawl remote MCP without breaking auth, streaming, tool discovery, or rate limits? |
| Figma | GitHub Copilot / VS Code | Figma documents remote and desktop MCP servers | Remote MCP endpoint `https://mcp.figma.com/mcp`; desktop local server | Risky for APIM gateway: Figma support forum indicates `mcp:connect` is not generally available for third-party OAuth apps and MCP access is limited to supported clients/integrations | Strong fit as remote/local registry entry, but runtime gateway fit is not proven | Confirmed for MCP; vendor support signal indicates arbitrary gateway/OAuth app may be blocked | Direct supported client first; A only after vendor validation | Can an APIM-fronted Figma MCP endpoint obtain/forward an accepted Figma OAuth session, or is Figma limited to the clients listed in the MCP catalog? |
| Contentful | GitHub Copilot / VS Code | Official Contentful GitHub repo provides `contentful-mcp-server` | Local `npx @contentful/mcp-server` using Contentful Management API token | Runtime gateway fit is weak if only local stdio is used; custom hosted wrapper may be possible | Strong fit as local package inventory | Confirmed for local MCP | B first, possible C later | Should Contentful be governed as a local MCP package, or should we host a wrapper and put APIM in front of it? |
| ESLint | GitHub Copilot / VS Code | ESLint official docs include MCP server setup | Local stdio via `npx @eslint/mcp@latest` | Not a runtime APIM case | Strong fit as local package inventory | Confirmed | B | How do we govern local MCP servers in VS Code: allowed package, version pinning, sandboxing, trust, and central policy? |
| CODESYS | GitHub Copilot / VS Code | No official CODESYS MCP server found in this research pass | CODESYS APIs/automation interfaces need separate verification | Not confirmed | Possible only as custom inventory if wrapper exists | Not confirmed | C only if API/automation interface is suitable | Is there an official CODESYS API/automation interface that can safely be wrapped as MCP, and what operations are acceptable? |
| Chrome DevTools MCP | Claude Desktop | Official ChromeDevTools GitHub repo provides MCP server | Local `npx chrome-devtools-mcp@latest`, controls local Chrome | Not a runtime APIM case for local desktop usage | Strong fit as local package/extension inventory | Confirmed | B | How do we govern a powerful local browser-control MCP server in Claude Desktop with allowlists, config, usage policy, and data-safety constraints? |

## Detailed Findings

### Supermetrics

Confirmed from official documentation:

- Supermetrics has AI chat integrations for Claude, ChatGPT, Gemini Enterprise, and Microsoft Copilot.
- Supermetrics states that AI chat integrations run through the Supermetrics MCP server in the background.
- Supermetrics also documents a standalone Supermetrics MCP server for custom integrations.
- For Microsoft Copilot, Supermetrics documents a "Try in Copilot" path and mentions a Microsoft 365 tenant with Teams enabled.

Sources:

- https://docs.supermetrics.com/docs/supermetrics-ai-features
- https://docs.supermetrics.com/v1/docs/supermetrics-mcp-server
- https://docs.supermetrics.com/v1/docs/how-to-connect-supermetrics-to-ai-tools

Assumptions:

- It may be possible to route the standalone Supermetrics MCP server through APIM, but this is not confirmed by Supermetrics documentation.
- For Microsoft 365 Copilot Chat, the better enterprise path may be the vendor-native Supermetrics AI chat integration rather than our own APIM-fronted MCP endpoint.

POC validation:

1. Identify whether Supermetrics exposes a stable remote MCP endpoint suitable for custom clients.
2. Test APIM in front of that endpoint with MCP Inspector or VS Code first.
3. Separately validate how Microsoft 365 Copilot Chat consumes Supermetrics: native connector, agent, or federated connector.
4. Decide whether APIM is part of the runtime path or only part of a custom integration path.

### Contentsquare

Confirmed from official documentation:

- Contentsquare has technical documentation and REST APIs such as Metrics API and Data Export API.
- The Metrics API is REST-based, uses HTTPS, and returns JSON.
- Data Connect can sync Contentsquare behavioral data into data warehouses.

Sources:

- https://docs.contentsquare.com/en/
- https://docs.contentsquare.com/en/api/metrics/
- https://docs.contentsquare.com/en/api/export/
- https://docs.contentsquare.com/en/connect/

Not confirmed:

- No official Contentsquare MCP server was found in this research pass.
- No official Contentsquare-to-Microsoft-Copilot MCP integration was found in this research pass.

Assumption:

- Contentsquare is a candidate for pattern C because it has APIs, but no confirmed official MCP server.

POC validation:

1. Confirm with Contentsquare docs or account team whether an official MCP server exists.
2. If not, select one low-risk API use case from Metrics API or Data Export API.
3. Test APIM REST-to-MCP for read-only tool exposure.
4. If APIM REST-to-MCP is insufficient, build a minimal custom MCP wrapper.

### Firecrawl

Confirmed from official documentation:

- Firecrawl has an MCP server.
- Firecrawl supports a remote hosted MCP URL.
- Firecrawl supports local `npx`.
- Firecrawl supports Streamable HTTP mode.
- Firecrawl documents VS Code and Claude Desktop setup.

Source:

- https://docs.firecrawl.dev/mcp-server

Assumption:

- Because Firecrawl provides a remote Streamable HTTP MCP endpoint and APIM supports remote MCP servers with Streamable HTTP/SSE, Firecrawl is a strong candidate for APIM gateway validation.

POC validation:

1. Register Firecrawl remote MCP in API Center.
2. Expose Firecrawl through APIM as an existing remote MCP server.
3. Validate `initialize`, `tools/list`, and one safe read-only tool call.
4. Validate auth behavior with and without Firecrawl API key.
5. Confirm APIM policy and logging do not break streaming.

### Figma

Confirmed from official documentation:

- Figma has a remote MCP server and a desktop MCP server.
- Figma recommends the remote MCP server for the broadest feature set.
- Figma documents `https://mcp.figma.com/mcp` as the remote MCP endpoint.
- Figma lists VS Code as supporting both desktop and remote server support.
- Some features such as write-to-canvas require the remote Figma MCP server and are supported by selected clients.
- Figma maintains an MCP catalog that lists supported MCP clients and their access model.

Source:

- https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server
- https://www.figma.com/mcp-catalog/

Vendor support/forum signal:

- A Figma Community Support response in the official Figma Forum states that the `mcp:connect` OAuth scope is not currently available for general third-party OAuth apps.
- The same response states that MCP access is currently limited to supported clients and integrations.
- Later posts in the same thread describe enterprise gateway/proxy use cases that appear blocked by the same OAuth/client-registration limitation.

Source:

- https://forum.figma.com/ask-the-community-7/how-to-access-mcp-oauth-scope-mcp-connect-50630

Assumption:

- The previous assumption that APIM can likely sit in front of the Figma remote MCP endpoint should be downgraded.
- Based on the vendor support/forum signal, APIM-fronted Figma Remote MCP may be blocked unless Figma supports or approves the gateway/client identity.
- Direct use from a listed supported client such as VS Code is a different case from routing through an enterprise gateway.

POC validation:

1. Test direct Figma Remote MCP from a supported client such as VS Code to establish the baseline.
2. Confirm whether the same flow works when APIM is inserted in front of Figma Remote MCP.
3. Validate the OAuth details explicitly:
   - Does Figma issue/accept a token with `mcp:connect`?
   - Does Dynamic Client Registration work for the gateway/client?
   - Does Figma reject the gateway as an unsupported third-party OAuth app?
4. Treat APIM-fronted Figma MCP as blocked until proven otherwise or until Figma confirms an enterprise/private gateway path.
5. If APIM-fronted remote MCP is blocked, evaluate the desktop/local Figma MCP model or a separate REST/API-based integration pattern.

### Contentful

Confirmed from official documentation/repository:

- Contentful has an official public GitHub repository `contentful/contentful-mcp-server`.
- The server exposes Contentful Management API capabilities to AI assistants.
- It is installed with `npx -y @contentful/mcp-server`.
- It uses environment variables such as `CONTENTFUL_MANAGEMENT_ACCESS_TOKEN`, `SPACE_ID`, and `ENVIRONMENT_ID`.
- It includes write-capable tools for content types, entries, assets, environments, locales, tags, and AI actions.
- It includes `PROTECTED_ENVIRONMENTS` to block write and delete operations for selected environments.

Source:

- https://github.com/contentful/contentful-mcp-server

Implication:

- Contentful is a confirmed local MCP candidate.
- Because the documented setup is local stdio, APIM is not naturally in the runtime path unless we host the MCP server ourselves or expose selected Contentful APIs through APIM.

POC validation:

1. Test as local VS Code MCP server first.
2. Restrict to non-production Contentful space/environment.
3. Validate `PROTECTED_ENVIRONMENTS`.
4. Decide if a hosted wrapper is required for enterprise gateway governance.

### ESLint

Confirmed from official documentation:

- ESLint CLI contains an MCP server.
- ESLint documents VS Code setup with `.vscode/mcp.json`.
- The documented transport is local stdio via `npx @eslint/mcp@latest`.
- ESLint documents using it with GitHub Copilot Agent mode.

Source:

- https://eslint.org/docs/latest/use/mcp

Implication:

- ESLint is a clean pattern B candidate.
- APIM is not relevant for runtime traffic.
- Governance should focus on package trust, version pinning, workspace config, sandboxing, and central policy.

POC validation:

1. Configure ESLint MCP in VS Code.
2. Pin or approve package/version.
3. Test VS Code sandboxing on macOS/Linux if applicable.
4. Document central enable/disable and trust workflow.

### CODESYS

Confirmed:

- No official CODESYS MCP server was found in this research pass.

Not confirmed:

- Whether CODESYS provides a suitable automation API or supported CLI surface for safe MCP wrapping.
- Whether any existing community MCP server is acceptable for enterprise use.

Assumption:

- CODESYS should be treated as pattern C only if a supported API/automation surface exists and if the use case can be scoped safely.

POC validation:

1. Verify official CODESYS automation interfaces and licensing constraints.
2. Define a low-risk read-only use case before any write/build/deploy operation.
3. If feasible, build a custom MCP wrapper around a narrow operation set.
4. Keep this separate from the remote SaaS MCP POCs because industrial automation tooling has a different risk profile.

### Chrome DevTools MCP

Confirmed from official repository:

- Chrome DevTools MCP is provided by the ChromeDevTools GitHub organization.
- It acts as an MCP server that lets coding agents control and inspect a live Chrome browser.
- It uses `npx chrome-devtools-mcp@latest`.
- It supports Copilot / VS Code installation and other clients.
- It exposes browser content to MCP clients and can inspect, debug, and modify browser data.

Source:

- https://github.com/ChromeDevTools/chrome-devtools-mcp

Implication:

- Chrome DevTools MCP is a strong local MCP candidate.
- It should not be treated as a normal remote gateway use case.
- Governance must focus on local execution risk, data exposure, browser session isolation, usage statistics settings, and tool approval.

POC validation:

1. Test with Claude Desktop local MCP or desktop extension mechanism.
2. Disable or document telemetry/update checks if required.
3. Use a non-sensitive browser profile.
4. Define allowed use cases and forbidden data contexts.

## Recommended POC Sequence

### POC A2: Remote Third-Party MCP Through APIM

Validated first candidate: Firecrawl.

Why:

- Official MCP server.
- Remote hosted URL.
- Streamable HTTP support.
- Lower enterprise auth complexity than Figma.
- Good fit for proving that the Microsoft Learn MCP POC generalizes to third-party remote MCP.

Figma is no longer recommended as the immediate fallback for APIM-fronted remote MCP. It should be tested only after a direct supported-client baseline and explicit OAuth/gateway validation, because vendor support/forum signals indicate that third-party OAuth apps and gateway/proxy scenarios may be blocked.

### POC B: Local MCP Governance

Validated first candidate: ESLint.

Why:

- Official docs.
- Low blast radius compared with browser automation or CMS write tools.
- Clear VS Code/GitHub Copilot path.
- Good for proving how API Center can inventory local MCP packages even when APIM is not in the runtime path.

Second candidate: Chrome DevTools MCP with Claude Desktop.

### POC C: API-To-MCP Or Custom Wrapper

Recommended first candidate: Contentsquare read-only Metrics API.

Why:

- No official MCP found.
- Official REST API exists.
- Read-only analytics query is easier to govern than write-capable content or campaign changes.
- APIM REST-to-MCP can be evaluated directly.

Alternative: Contentful hosted wrapper, but only with a non-production space and write protections.

### POC D: Microsoft 365 Copilot Chat Integration

Recommended first candidate: Supermetrics.

Why:

- Supermetrics officially documents Microsoft Copilot integration and a Supermetrics MCP server.
- Microsoft 365 Copilot officially supports federated connectors using MCP.
- This is the closest fit to the business/marketing scenario.

Key open question:

- Should the enterprise architecture use Supermetrics' vendor-native Copilot integration, a Microsoft 365 federated connector, or an APIM-fronted MCP endpoint?

## Open Questions

| Question | Why It Matters | How To Validate |
| --- | --- | --- |
| Can Microsoft 365 Copilot Chat consume an APIM-fronted MCP endpoint directly through federated connectors? | Determines whether our APIM gateway is in the Microsoft Copilot runtime path | Build a minimal federated connector pointing to APIM |
| Can APIM proxy Figma remote MCP without being rejected as an unsupported client/gateway? | Determines if Figma can fit pattern A at all | Test direct supported-client flow first, then APIM-fronted flow; confirm `mcp:connect`, Dynamic Client Registration, and vendor support status |
| Can APIM proxy Firecrawl remote MCP with API-key auth and streaming intact? | Best next remote MCP generalization test | Keyless APIM proxy path validated; API-key-backed vendor calls remain to be tested |
| Should local MCP servers be governed by API Center inventory only? | Determines role of API Center for pattern B | ESLint local MCP runtime validated; API Center inventory and enterprise host policy remain to be tested |
| Can APIM REST-to-MCP cover Contentsquare use cases without custom code? | Determines whether pattern C can be low-code | Expose one Contentsquare REST operation as MCP tool in APIM |
| Is CODESYS MCP feasible and safe? | Industrial automation risk is higher than ordinary SaaS | Verify official CODESYS automation APIs and define a read-only pilot |
