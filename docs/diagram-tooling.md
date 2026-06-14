# Diagram Tooling Research

This note captures the current diagram tooling direction for this repository.

## Question

Are Mermaid diagrams the best option for architecture sketches generated and maintained with an agent such as Codex?

## Short Answer

Mermaid is the best default for diagrams embedded directly in GitHub Markdown. It is not necessarily the best tool for polished architecture diagrams.

For this repository:

- Use Mermaid for README-native diagrams.
- Evaluate D2 for prettier generated SVG diagrams.
- Consider LikeC4 or Structurizr if the architecture grows into a larger architecture-as-code model.

## Options

| Tool | Strength | Weakness | Fit For This Repo |
| --- | --- | --- | --- |
| Mermaid | GitHub-native rendering, easy Markdown embedding, simple agent edits | Layout and visual polish are limited | Best default for README diagrams |
| D2 | Clean text syntax, good-looking generated diagrams, SVG/PNG export | GitHub does not render D2 directly | Best next experiment for polished diagrams |
| LikeC4 | C4-inspired architecture-as-code, interactive views, AI-friendly DSL, validation | Adds a toolchain and static build output | Good if the model grows |
| Structurizr DSL | Mature C4 model, multiple views from one model, exports to Mermaid/PlantUML/SVG | More formal, more setup | Best for serious architecture repositories |
| PlantUML / C4-PlantUML | Mature UML/C4 ecosystem | Not GitHub-native without rendering tooling | Useful for teams already using PlantUML |
| diagrams.net | Great manual diagrams | XML source is awkward for agent edits and reviews | Good for manual design, less ideal here |

## Recommendation

Use a two-layer strategy:

1. **README layer**: Mermaid diagrams embedded directly in Markdown.
2. **Polished architecture layer**: D2 source files rendered to SVG and embedded in the README.

If the system becomes larger, introduce a formal architecture model:

1. LikeC4 for a modern, agent-friendly C4 workflow.
2. Structurizr DSL for a mature C4 model with strong tooling.

## Sources

- GitHub supports Mermaid diagrams directly in Markdown: https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams
- Mermaid documentation: https://mermaid.js.org/intro/
- D2 documentation: https://d2lang.com/tour/intro/
- LikeC4: https://likec4.dev/
- Structurizr DSL: https://docs.structurizr.com/dsl
- PlantUML: https://plantuml.com/
