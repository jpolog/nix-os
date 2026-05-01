# Conversation Context

This is a summary of the parent conversation. Read this if you need additional context about what was discussed or decided.

## User

docker:mom-sandbox

## User

/home/jpolo

## User

.

## User

can you use the phd agents? are they activated?

## Assistant

Yes — all 9 PhD Research Team agents are available as subagents in the `task` tool. I can dispatch them for parallel or sequential work.

Available agents:

| Agent | Use for |
|---|---|
| `res-phd-academic-writer` | Writing, revising, polishing academic text |
| `res-phd-peer-reviewer` | Rigorous academic peer review |
| `res-phd-literature-searcher` | Finding academic literature across databases |
| `res-phd-plagiarism-guard` | Plagiarism risk, AI-artifact detection, style consistency |
| `res-phd-literature-retriever` | Retrieving/downloading full-text papers |
| `res-phd-literature-reviewer` | Deep reading, analysis, synthesis of literature |
| `res-phd-research-methodologist` | Designing research methodology |
| `res-phd-data-analyst` | Statistical analysis, data visualization, results interpretation |
| `res-phd-citation-formatter` | Formatting citations and bibliographies (APA, IEEE, etc.) |

Paired skills I'll reference for conventions: `skill://academic-writing`, `skill://literature-search`, `skill://style-guard`, `skill://literature-retrieval`.

What are you working on? Give me the research task and I'll route it to the right agents.

## User

try to research good academic citations and references for a "co-creation system with llms". I want to use them in the "related work" part of my project. Put those findings in a file called related-work.md

## User

we are in 2026, not 2025 so you can include more recent work if you find it