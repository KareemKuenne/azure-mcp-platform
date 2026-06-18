# MCP Governance Model

This document is a work-in-progress governance model for extending the Azure MCP Platform POC beyond the initial Microsoft Learn MCP integration.

The goal is not to define a final enterprise standard yet. The goal is to create a structured starting point for discussion, testing, and communication.

## Purpose

MCP introduces a new integration layer between AI hosts and external systems. That is useful, but it also creates governance questions:

- Which MCP servers are approved?
- Which hosts may use them?
- Which tools, resources, and prompts are exposed?
- Where does runtime traffic flow?
- Who owns authentication, logging, risk review, and lifecycle management?
- Which controls are technical runtime controls and which are catalog, policy, or process controls?

This document separates those questions by integration pattern.

## Key Concepts

| Concept | Meaning | Governance Implication |
| --- | --- | --- |
| MCP host | The AI application that consumes MCP capabilities | Must be trusted and configured |
| MCP server | The system exposing tools, resources, or prompts | Must be reviewed, approved, and owned |
| Tool | An executable operation the model can invoke | Needs risk classification and approval rules |
| Resource | Readable contextual data exposed to the host | Needs data classification and access control |
| Prompt | Reusable task template exposed by the server | Needs content review and user-facing clarity |
| Registry | Catalog of approved MCP servers and metadata | Helps discovery, ownership, lifecycle, and audit |
| Gateway | Runtime control point for network MCP traffic | Enables auth, policy, rate limits, routing, and logs |
| Local MCP | MCP server running on a developer machine | Needs host, package, repo, and endpoint controls |

## Capability Types

MCP distinguishes between tools, resources, and prompts. They can look similar from a user perspective, but they are different protocol capabilities.

| Capability | Controlled By | Main Use | Example Governance Question |
| --- | --- | --- | --- |
| Tools | Model-driven, with host/user controls | Execute operations or API calls | Can this tool write, delete, spend money, publish, or exfiltrate data? |
| Resources | Application/user-driven | Provide context to the model | What data classification is exposed, and who may read it? |
| Prompts | User-driven | Start predefined workflows | Is the prompt accurate, safe, and aligned with approved process? |

For REST APIs exposed through API Management as MCP, the first practical capability is usually a set of tools. A read-only REST `GET` operation can still become a useful MCP tool. The limitation is not that information cannot be queried; the limitation is that API Management does not automatically expose the REST API as MCP resources or prompts.

## Integration Patterns

## Registry And Enforcement Model

The registry is the central source of truth for approved MCP servers, but the registered runtime target depends on the integration pattern.

| Pattern | What The Registry Should Contain | Runtime Path | Enforcement Point |
| --- | --- | --- | --- |
| Remote MCP through gateway | The APIM-fronted MCP endpoint, not the vendor's direct endpoint | AI host -> APIM -> remote MCP server | GitHub/VS Code MCP policy allows registry entries; APIM enforces runtime policy |
| Local MCP package | The approved local package, command, version, and configuration metadata | AI host -> local stdio process -> local MCP server | GitHub/VS Code MCP policy allows registry entries; local controls govern execution |
| REST API to MCP | The APIM-exposed MCP endpoint or approved custom wrapper | AI host -> APIM -> REST API or wrapper | GitHub/VS Code MCP policy allows registry entries; APIM enforces runtime policy |
| Microsoft 365 Copilot integration | The approved connector, agent, vendor-native integration, or APIM-fronted MCP endpoint | Depends on selected Copilot extension model | Microsoft 365 admin controls, connector governance, and optionally APIM |

For remote MCP, the registry should normally expose only the enterprise-controlled gateway endpoint. The direct vendor MCP endpoint should not be published as an approved entry unless bypassing the gateway is an explicit decision.

For local MCP, the registry can approve the package and configuration, but it does not route runtime traffic. The local MCP server still runs on the developer workstation.

This means the target operating model is:

1. API Center stores the approved MCP catalog.
2. GitHub Copilot / VS Code policy is configured to allow only MCP servers from the configured registry.
3. Remote MCP and REST/API-to-MCP entries point to APIM whenever runtime gateway governance is required.
4. Local MCP entries point to approved local packages and commands.
5. Additional endpoint, package, sandbox, and device controls are required for local execution risk.

### Pattern A: Remote MCP Through Enterprise Gateway

Runtime flow:

```text
AI Host
  -> Azure API Management
  -> Remote MCP Server
  -> Vendor or Platform System
```

Recommended for:

- Remote MCP servers with HTTP/SSE/Streamable HTTP transport.
- Use cases where runtime governance is important.
- Third-party MCP servers that allow enterprise gateway/proxy access.

Primary Azure roles:

| Azure Component | Role |
| --- | --- |
| Azure API Center | Registry and governance metadata |
| Azure API Management | Runtime gateway and policy enforcement |
| Azure Monitor / APIM logs | Observability and audit evidence |

Candidate POCs:

| Candidate | Current View |
| --- | --- |
| Microsoft Learn MCP | Already validated in the initial POC |
| Firecrawl | Validated as third-party remote MCP candidate in a follow-up POC |
| Figma | MCP confirmed, but gateway/OAuth compatibility is risky and must be validated before treating it as pattern A |

Possible controls:

| Control Area | Example |
| --- | --- |
| Registry target | Register the APIM endpoint, not the direct vendor MCP endpoint |
| Authentication | Subscription key for POC; Entra ID/OAuth target architecture |
| Authorization | Product/API access, scopes, claims, allowlists |
| Rate limiting | APIM rate-limit policy |
| Routing | Only approved upstream MCP endpoints |
| Logging | Request metadata, status, latency, caller identity |
| Tool filtering | Future policy or wrapper-level control, depending on server capabilities |
| Data loss prevention | Avoid logging sensitive payloads; classify exposed tools/resources |

Known limitations:

- Gateway insertion may break vendor OAuth flows if the vendor only supports allowlisted clients.
- MCP streaming responses should not be buffered in APIM policies.
- Some MCP capabilities may not be fully supported by APIM depending on the exposure model.

### Pattern B: Local MCP Package Governance

Runtime flow:

```text
AI Host on Developer Machine
  -> local stdio process
  -> local MCP server
  -> local files, local tools, or remote APIs
```

Recommended for:

- Developer tooling.
- Local source-code analysis.
- Browser/devtools automation.
- Tools that are designed to run on a workstation.

Primary governance point:

API Management is not in the runtime path. Governance must be implemented through host policy, repository configuration, approved package inventories, endpoint management, and developer standards.

The registry entry for a local MCP server should describe the approved package and command, for example an `npx` package, version, arguments, required environment variables, sandbox settings, and supported hosts. It should not point to an APIM runtime endpoint unless the local server is intentionally wrapped or hosted elsewhere.

Candidate POCs:

| Candidate | Current View |
| --- | --- |
| ESLint MCP | Validated as local MCP governance POC with VS Code and GitHub Copilot |
| Chrome DevTools MCP | Useful but higher risk because it controls a browser session |
| Contentful MCP | Confirmed local MCP, but write-capable and therefore higher risk |

Possible controls:

| Control Area | Example |
| --- | --- |
| Registry | API Center entry for approved local MCP package |
| Workspace config | Reviewed `.vscode/mcp.json` checked into trusted repos |
| Host policy | VS Code/GitHub MCP policy set to registry-only access where available |
| Package control | Version pinning, internal npm proxy, package allowlist |
| Runtime safety | VS Code sandboxing where available |
| User approval | Tool confirmation prompts for risky actions |
| Endpoint control | MDM/EDR rules for process execution and network access |
| Secrets handling | No tokens in repo config; use environment variables or secret stores |

Important distinction:

API Center can document and approve a local MCP package, but API Center alone does not technically prevent a developer from running an unapproved local MCP server. Registry-only enforcement depends on the MCP host honoring enterprise policy. Runtime execution risk still requires additional controls such as managed VS Code settings, GitHub Copilot organization policy, package allowlists, sandboxing, endpoint management, and monitoring.

### Pattern C: REST API To MCP Or Custom Wrapper

Runtime flow option 1:

```text
AI Host
  -> Azure API Management
  -> REST API exposed as MCP tools
  -> Vendor API
```

Runtime flow option 2:

```text
AI Host
  -> Azure API Management
  -> Custom MCP Wrapper
  -> Vendor API
```

Recommended for:

- Vendors with useful REST APIs but no official MCP server.
- Read-only analytics or reporting scenarios.
- Cases where we need strong control over tool shape and permissions.

Candidate POCs:

| Candidate | Current View |
| --- | --- |
| Contentsquare | Best first REST/API-to-MCP candidate if a read-only API token is available |
| Contentful hosted wrapper | Possible but write-capable, so should start in a non-production space |
| CODESYS | Not confirmed; requires separate API and safety assessment |

Possible controls:

| Control Area | Example |
| --- | --- |
| Tool design | Expose only narrow, purpose-built operations |
| Read/write separation | Start with read-only tools |
| Input validation | Schema-level and policy-level validation |
| Auth | APIM validates client; backend auth stored securely |
| Logging | Log tool name, caller, status, duration, not sensitive payloads |
| Cost/rate control | APIM rate limits and quotas |
| Data classification | Limit which data classes are exposed to AI hosts |

Design preference:

Start with narrow tools instead of exposing a broad API surface. A small, clearly described tool is easier to govern than a generic API passthrough.

### Pattern D: Microsoft 365 Copilot Chat Integrations

Runtime possibilities:

```text
Microsoft 365 Copilot Chat
  -> Vendor-native Copilot integration
  -> Vendor platform
```

```text
Microsoft 365 Copilot Chat
  -> Microsoft 365 agent or federated connector
  -> MCP endpoint
  -> Vendor/platform system
```

```text
Microsoft 365 Copilot Chat
  -> Microsoft 365 agent or federated connector
  -> Azure API Management
  -> MCP endpoint
  -> Vendor/platform system
```

Recommended for:

- Business-user-facing data access.
- Microsoft 365 tenant-integrated experiences.
- Systems that already provide Microsoft Copilot integrations.

Candidate POCs:

| Candidate | Current View |
| --- | --- |
| Supermetrics | Best first Microsoft 365 Copilot Chat candidate because vendor documentation mentions Copilot and MCP |
| Contentsquare | Possible later candidate through connector/custom MCP path if no native integration exists |

Governance trade-off:

| Approach | Governance Strength | Trade-Off |
| --- | --- | --- |
| Vendor-native Copilot integration | Strong vendor support and simpler onboarding | Less Azure gateway control |
| Microsoft federated connector | Better Microsoft 365 alignment | Needs connector design, tenant/admin validation, and MCP compatibility |
| APIM-fronted MCP endpoint | Strong Azure runtime governance | Must prove Microsoft 365 Copilot accepts the endpoint/auth model |

Open question:

For Microsoft 365 Copilot Chat, the extension surface is not the same as VS Code Remote HTTP MCP. We should not assume that any arbitrary MCP URL can be entered directly. The next step is to validate the supported Microsoft 365 extension model for the selected vendor/use case.

## Governance Decision Matrix

| Question | Pattern A | Pattern B | Pattern C | Pattern D |
| --- | --- | --- | --- | --- |
| Is APIM in runtime path? | Yes | No | Yes, unless wrapper is local only | Maybe |
| Is API Center useful? | Yes | Yes, as inventory | Yes | Yes, as inventory/reference |
| Can runtime calls be rate-limited centrally? | Yes | Not through APIM | Yes | Depends on integration path |
| Can local execution risk exist? | Low | High | Low/medium | Low |
| Best first POC | Firecrawl | ESLint | Contentsquare read-only API | Supermetrics |
| Main uncertainty | Vendor auth/gateway compatibility | Local enforcement model | Tool design and backend auth | Microsoft 365 connector model |

## Minimum Metadata For Registry Entries

Each approved MCP server or package should have at least the following metadata:

| Field | Purpose |
| --- | --- |
| Name | Human-readable server name |
| Pattern | A, B, C, or D |
| Owner | Team or person accountable for lifecycle |
| Host compatibility | Approved hosts, such as VS Code, Claude Desktop, Microsoft 365 Copilot |
| Runtime location | Remote, local, APIM-fronted, vendor-native, custom wrapper |
| Transport | HTTP, SSE, Streamable HTTP, stdio, desktop extension |
| Auth model | Subscription key, OAuth, API key, local env var, vendor-managed |
| Capability types | Tools, resources, prompts |
| Tool risk | Read-only, write-capable, destructive, browser-control, deploy-capable |
| Data classification | Public, internal, confidential, restricted |
| Approved version | Package version or endpoint version |
| Documentation | Setup and usage instructions |
| Review status | Proposed, approved for POC, approved for production, deprecated |

## Suggested POC Sequence

| Order | POC | Goal | Needs Credentials? |
| --- | --- | --- | --- |
| 1 | Firecrawl through APIM | Prove third-party remote MCP gateway pattern | Validated keyless for discovery/tool calls; API key needed for full vendor usage |
| 2 | ESLint local MCP | Prove local MCP inventory and workstation governance model | Validated without credentials |
| 3 | Contentsquare REST/API-to-MCP | Prove REST-to-MCP or wrapper pattern | Yes, Contentsquare API access |
| 4 | Supermetrics with Microsoft 365 Copilot Chat | Prove Microsoft 365 Copilot integration pattern | Yes, M365 tenant/admin and Supermetrics access |
| 5 | Chrome DevTools local MCP | Prove high-risk local MCP controls | No vendor credential, but local browser safety setup |
| 6 | Figma | Validate supported-client vs gateway/OAuth limitation | Yes, Figma account and possibly vendor clarification |

## What The Platform Team Owns

| Responsibility | Description |
| --- | --- |
| Registry model | Define metadata, lifecycle states, ownership, and approval process |
| Gateway pattern | Build and operate APIM-based runtime controls for remote MCP/API-to-MCP |
| Host standards | Define supported AI hosts and approved configuration patterns |
| Package standards | Define how local MCP packages are approved, pinned, and distributed |
| Security baseline | Define authentication, authorization, logging, data classification, and review expectations |
| Developer enablement | Provide examples, templates, and runbooks |
| POC validation | Test assumptions before promoting patterns |

## What Application Or Product Teams Own

| Responsibility | Description |
| --- | --- |
| Use-case definition | Explain what business or developer task the MCP server supports |
| Data ownership | Confirm data classification and access boundaries |
| Vendor credentials | Provide non-production API keys or OAuth setup where needed |
| Tool approval | Confirm which tools are safe and useful |
| Functional testing | Validate that the integration solves the real workflow |

## Open Governance Questions

| Question | Why It Matters | Suggested Validation |
| --- | --- | --- |
| Should local MCP servers require central approval before use? | Determines how strict workstation governance must be | ESLint local MCP POC validated the runtime path; central policy enforcement remains the next validation |
| Should APIM block or allow tool calls by tool name? | Determines depth of runtime governance | Firecrawl APIM POC validated gatewaying; tool-level policy remains the next validation |
| Should write-capable tools require human approval every time? | Reduces risk of destructive actions | Contentful or Chrome DevTools POC |
| Should registry metadata be manually curated or generated from MCP discovery? | Affects operational effort and accuracy | Compare API Center metadata with runtime MCP discovery |
| Should vendor-native Copilot integrations be allowed when APIM is not in path? | Determines governance posture for Microsoft 365 Copilot | Supermetrics POC |

## Current Position

The current recommendation is:

1. Use APIM and API Center for remote MCP and API-to-MCP patterns.
2. Use API Center as inventory for local MCP servers, but do not treat it as runtime enforcement.
3. Use the ESLint local MCP POC as the baseline for low-risk developer-tool governance.
4. Treat high-risk local MCP servers, such as browser-control or write-capable CMS tooling, as separate security reviews.
5. Validate Microsoft 365 Copilot Chat through its official extension model before assuming arbitrary MCP endpoint support.
6. Prefer read-only POCs before write-capable POCs.

## References

| Topic | Source |
| --- | --- |
| MCP server concepts | https://modelcontextprotocol.io/docs/learn/server-concepts |
| Azure API Management existing MCP server | https://learn.microsoft.com/en-us/azure/api-management/expose-existing-mcp-server |
| Azure API Management REST API as MCP | https://learn.microsoft.com/en-us/azure/api-management/export-rest-mcp-server |
| Azure API Center MCP registry | https://learn.microsoft.com/en-us/azure/api-center/register-discover-mcp-server |
| VS Code MCP servers | https://code.visualstudio.com/docs/agent-customization/mcp-servers |
| Microsoft 365 Copilot connectors | https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview-copilot-connector |
| Compatibility assessment | ./mcp-compatibility-assessment.md |
