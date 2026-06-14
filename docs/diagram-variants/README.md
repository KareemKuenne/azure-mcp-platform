# Diagram Variants

This folder contains alternative diagram source formats for the same Azure MCP Platform architecture.

The goal is to compare readability, maintainability, and visual quality before choosing a long-term diagram tooling strategy.

## Variants

| Variant | Source | Rendered output | Notes |
| --- | --- | --- | --- |
| Mermaid | [mermaid/system-context.mmd](mermaid/system-context.mmd) | GitHub renders Mermaid in Markdown | Best native README support |
| D2 | [d2/system-context.d2](d2/system-context.d2) | [d2/system-context.svg](d2/system-context.svg) | Better visual layout, generated artifact required |
| PlantUML | [plantuml/system-context.puml](plantuml/system-context.puml) | Not rendered in GitHub by default | Mature, common in enterprise documentation |
| LikeC4 | [likec4/azure-mcp-platform.c4](likec4/azure-mcp-platform.c4) | Requires LikeC4 tooling | Strong candidate for architecture-as-code |

## Evaluation Criteria

Use these criteria when reviewing the variants:

- Is the diagram readable without explanation?
- Does the source format look easy for Codex and humans to edit?
- Does it render well in GitHub or require generated images?
- Does it scale to multiple architecture views?
- Does it feel professional enough for public documentation?

## Current Recommendation

Keep Mermaid in the README for now because GitHub renders it natively.

Use this folder to evaluate whether D2, LikeC4, or PlantUML should become the preferred source format for polished architecture diagrams.
