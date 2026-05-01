# Skill: Docs
## Purpose
Forces the agent to use the `documenter` role (Llama 4 mini) specifically for writing JSDoc, READMEs, and architectural summaries to save on Tier 1 token costs.

## Instructions
- When writing documentation, JSDoc, or READMEs, ALWAYS switch to the `documenter` role.
- Prioritize concise and clear technical writing.
- Use the `ollama/llama-4-mini:cloud` model via the `documenter` role for all documentation tasks.

## Routing Logic
- Trigger: Documentation requests, README updates, JSDoc generation.
- Role: documenter
