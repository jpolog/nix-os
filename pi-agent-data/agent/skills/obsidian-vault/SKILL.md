---
name: obsidian-vault
description: Manage Obsidian vaults — navigate folder structure, create and edit notes, maintain frontmatter, wikilinks, and Obsidian-specific syntax. Use when working with .md files in Obsidian vaults, creating notes, editing content, or answering questions about vault contents.
globs:
  - "**/*.md"
alwaysApply: false
---

# Obsidian Vault Skill

Navigate, create, and edit notes in two Obsidian vaults using Obsidian Flavored Markdown conventions.

## Vaults

| Vault | Path | Purpose |
|---|---|---|
| Knowledge Base | `/home/jpolo/Vault/Knowledge Base` | Personal knowledge: books, ideas, journal, research, linux, homelab |
| PhD | `/home/jpolo/Vault/phd` | Academic research: literature, experiments, concepts, projects |

When the vault is ambiguous, ask the user which vault to use.

## Folder Structure

Both vaults share the same numbered folder scheme. The number prefix determines sort order:

| Folder | Purpose | KB Content | PhD Content |
|---|---|---|---|
| `00_Inbox` | Unprocessed captures | Quick notes, ideas | New papers, unsorted items |
| `10_Projects` | Active projects | Side projects, learning paths | Research projects, experiments |
| `20_Literature` | Sources and papers | Book notes, articles | Papers, reviews, Zotero imports |
| `30_Concepts` | Definitions and concepts | Topic notes | Concept notes, flashcards |
| `40_Network` | People and contacts | — | Researchers, advisors, students |
| `50_Atlas` | Maps and diagrams | Maps, diagrams | System maps, architecture diagrams |
| `60_Calendar` | Time-based notes | Journal, daily logs | Daily notes, meetings |
| `80_Admin` | Administration | Config, meta | Admin, submissions |
| `90_Archives` | Completed items | Finished projects | Inactive projects |
| `99_System` | System files | Templates, config | Templates, config |

## Creating a New Note

1. Determine which vault
2. Determine note type (see skill://obsidian-templates for template selection)
3. Pick the correct folder based on the table above
4. Apply the correct template
5. Fill in the user's content
6. Validate by re-reading the file

### File Naming

- Use descriptive names: `Adaptive Instructional System (AIS).md`, not `ais.md`
- Spaces are allowed (Obsidian handles them)
- Parentheses for disambiguation: `Smith, J. (2023) — Paper Title.md`
- For PhD literature: use the citekey or author-year format matching the Zotero convention

## Editing Existing Notes

1. Read the existing note first
2. Understand its frontmatter and section structure
3. Make surgical edits that preserve structure
4. Never drop frontmatter fields, never reorder them
5. Preserve wikilinks `[[Note]]` — never convert to markdown links
6. Never break dataview queries
7. Validate by re-reading after editing

## Frontmatter Conventions

Frontmatter uses YAML between `---` delimiters. Each note type has a specific schema. See [frontmatter-schemas.md](references/frontmatter-schemas.md) for all schemas.

Common frontmatter fields across all note types:
- `type`: The note type (concept, idea, project, source/paper, daily, meeting, person, experiment, dataset, lab, student)
- `tags`: YAML list of tags
- `date_created`: ISO date (YYYY-MM-DD)
- `aliases`: YAML list of alternative names

## Obsidian Flavored Markdown

See [obsidian-markdown.md](references/obsidian-markdown.md) for the full reference. Key points:

- Use `[[wikilinks]]` for internal links, never `[text](path.md)`
- Use `![[embeds]]` for embedding content from other notes
- Use `> [!type]` callouts for highlighted information
- Use `==highlights==` for emphasizing text
- Use `%%comments%%` for content hidden in reading view
- Use `^block-id` for creating linkable block references

## Vault-Specific Behavior

### Knowledge Base
- Informal conventions OK
- Uses `utils/templates/book-template.md` for book notes
- Journal entries in `journal/` subfolders (log, dream diary, tasks)
- More relaxed structure — ideas, research notes, and topics are fine

### PhD Vault
- Strict frontmatter required on all new notes
- Uses `99_System/Templates/` with 12 structured templates
- Dataview queries power dashboards — do not break them
- Zotero integration for literature imports
- Templater syntax (`<% tp.date.now(...) %>`) should be pre-rendered with actual values when creating notes

## What NOT To Do

- Never modify `.obsidian/` internals
- Never convert wikilinks to markdown links
- Never remove frontmatter fields from existing notes
- Never break dataview code blocks
- Never place notes in the wrong numbered folder
- Never create notes without applying the correct template