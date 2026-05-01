---
name: obsidian-templates
description: Create new Obsidian notes using the correct template for each note type. Use when creating new notes, pages, or entries in Obsidian vaults. Contains all vault templates with pre-rendered Templater expressions for direct use by agents.
globs:
  - "**/*.md"
alwaysApply: false
---

# Obsidian Templates

Create new notes with the correct template for each note type and vault.

## Template Selection

### Decision Flowchart

```
What are you creating?
├── A definition or concept → Concept Note → references/concept-note.md
├── A research hypothesis → Research Idea → references/research-idea.md
├── A project overview → Project Dashboard → references/project-dashboard.md
├── A literature/paper note → Zotero Import → references/zotero-import.md
├── A daily log → Daily Note → references/daily-note.md
├── A meeting record → Meeting → references/meeting.md
├── A person/contact → Person → references/person.md
├── An experiment log → Experiment Log → references/experiment-log.md
├── A dataset description → Dataset → references/dataset.md
├── A lab description → Lab → references/lab.md
├── A student record → Student → references/student.md
└── A book summary (KB vault) → Book Template → references/book-template.md
```

### Which Vault?

- **PhD vault** (`/home/jpolo/Vault/phd`): Has all 12 templates in `99_System/Templates/`. Use for academic content.
- **Knowledge Base** (`/home/jpolo/Vault/Knowledge Base`): Has `utils/templates/book-template.md` for book notes. Other notes are less structured — use appropriate frontmatter from the vault skill.

## Template Placeholder System

Templates contain Templater expressions that must be pre-rendered when creating notes. Replace:

| Templater Expression | Replace With | Example |
|---|---|---|
| `<% tp.date.now("YYYY-MM-DD") %>` | Today's date | `2026-05-01` |
| `<% tp.date.now("YYYY-MM-DD", -1) %>` | Yesterday's date | `2026-04-30` |
| `<% tp.date.now("YYYY-MM-DD", 1) %>` | Tomorrow's date | `2026-05-02` |
| `<% tp.date.now("HH:mm") %>` | Current time | `14:30` |
| `<% tp.file.title %>` | The note's filename (without .md) | `My New Concept` |
| `<% tp.date.now("YYYYMMDD-HHmm") %>` | Timestamp for IDs | `20260501-1430` |

For the Zotero Import template, replace Zotero-specific placeholders (`{{citekey}}`, `{{title}}`, etc.) with actual values from the user. If the user is importing from Zotero, they should provide these values.

## Creating a Note — Step by Step

1. Determine note type and vault
2. Look up the template in the appropriate reference file
3. Determine the target folder using the vault-structure reference
4. Create the file at the correct path with pre-rendered content
5. Fill in the user's content in the appropriate sections
6. Validate by re-reading the file

### Example: Creating a Concept Note

```
Vault: /home/jpolo/Vault/phd
Type: concept
Folder: 30_Concepts/
File: 30_Concepts/My New Concept.md
Template: references/concept-note.md
```

### Example: Creating a Literature Note

```
Vault: /home/jpolo/Vault/phd
Type: source/paper
Folder: 00_Inbox/ (initial), then 20_Literature/ (after review)
File: 00_Inbox/smith2025method.md
Template: references/zotero-import.md
```

## Template Reference Files

Each reference file contains the complete pre-rendered template. Click through to get the full template content:

| Note Type | Reference File | PhD | KB |
|---|---|---|---|
| Concept Note | [concept-note.md](references/concept-note.md) | ✅ | — |
| Research Idea | [research-idea.md](references/research-idea.md) | ✅ | — |
| Project Dashboard | [project-dashboard.md](references/project-dashboard.md) | ✅ | — |
| Zotero Import | [zotero-import.md](references/zotero-import.md) | ✅ | — |
| Daily Note | [daily-note.md](references/daily-note.md) | ✅ | — |
| Meeting | [meeting.md](references/meeting.md) | ✅ | — |
| Person | [person.md](references/person.md) | ✅ | — |
| Experiment Log | [experiment-log.md](references/experiment-log.md) | ✅ | — |
| Dataset | [dataset.md](references/dataset.md) | ✅ | — |
| Lab | [lab.md](references/lab.md) | ✅ | — |
| Student | [student.md](references/student.md) | ✅ | — |
| Book Note | [book-template.md](references/book-template.md) | — | ✅ |

## Notes Without Templates

For the Knowledge Base vault, many note types don't have formal templates. In these cases:
- Add minimal frontmatter: `type`, `tags`, `date_created`
- Follow the folder conventions from skill://obsidian-vault
- Keep the structure simple and informal