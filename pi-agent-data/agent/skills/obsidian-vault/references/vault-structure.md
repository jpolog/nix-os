# Vault Structure Reference

## Knowledge Base (`/home/jpolo/Vault/Knowledge Base`)

### Folder Map

| Path | Purpose | Typical Content |
|---|---|---|
| `00_Inbox/` | Quick captures, unprocessed notes | Fleeting notes, web clippings |
| `10_Projects/` | Active projects | Side projects, learning paths |
| `20_Literature/` | Book notes, articles | Book summaries using book-template |
| `30_Concepts/` | Topic definitions | Concept notes, definitions |
| `40_Network/` | People and contacts | Contact notes (used sparingly) |
| `50_Atlas/` | Maps and diagrams | System maps, architecture diagrams |
| `60_Calendar/` | Time-based entries | Daily logs, journals |
| `80_Admin/` | Administration | Config, meta files |
| `90_Archives/` | Completed items | Finished projects |
| `99_System/` | System files | Templates, config |

### Additional Paths
- `culture/` — Books, ideas (culture/books, culture/ideas)
- `research/` — Research topics
- `linux/` — Linux tips and app notes
- `homelab/` — Homelab configuration
- `journal/` — Journal entries (log/, dream diary/, tasks/)
- `organize/` — Organization notes
- `utils/templates/` — Templates (currently: book-template.md)
- `Excalidraw/` — Excalidraw drawings

### Conventions
- Book notes use the `utils/templates/book-template.md` template
- Journal entries are in `journal/log/YYYY-MM-DD.md` format
- Task notes are in `journal/tasks/` with task data in filenames
- The vault uses Templater for template expansion
- Wikilinks are the primary linking mechanism
- Tags and frontmatter are used but less strictly than the PhD vault

---

## PhD Vault (`/home/jpolo/Vault/phd`)

### Folder Map

| Path | Purpose | Note Types | Template |
|---|---|---|---|
| `00_Inbox/` | Unprocessed captures | All types (temporary) | Any (quick capture) |
| `10_Projects/` | Active research projects | `project` | Project Dashboard |
| `10_Projects/_Reviews/` | Paper reviews | Review notes | (ad-hoc) |
| `20_Literature/` | Papers and sources | `source/paper` | Zotero Import |
| `30_Concepts/` | Concept definitions | `concept` | Concept Note |
| `40_Network/` | People and contacts | `person` | Person |
| `50_Atlas/` | Maps and diagrams | (varies) | (ad-hoc) |
| `60_Calendar/` | Time-based entries | `daily`, `meeting` | Daily Note, Meeting |
| `80_Admin/` | Administration | (varies) | (ad-hoc) |
| `90_Archives/` | Completed items | (varies) | (ad-hoc) |
| `99_System/Templates/` | Template files | — | — |

### Template Files
All templates are in `99_System/Templates/`:
- `Concept Note.md`
- `Research Idea.md`
- `Project Dashboard.md`
- `Zotero Import.md`
- `Zotero Import Review.md`
- `Daily Note.md`
- `Meeting.md`
- `Person.md`
- `Experiment Log.md`
- `Dataset.md`
- `Lab.md`
- `Student.md`

### Conventions
- **Strict frontmatter required** on all new notes
- Every note type has a corresponding template
- Dataview queries power project dashboards and literature reviews
- Zotero Integration plugin imports PDFs and annotations
- Templater expressions in templates must be pre-rendered when creating notes
- Wikilinks `[[Note]]` are the primary linking mechanism
- Note titles come from filenames (Obsidian convention)

### Note Placement Rules
- New concept notes → `30_Concepts/`
- New literature imports → `00_Inbox/` first, then `20_Literature/` after review
- New project dashboards → `10_Projects/`
- New experiment logs → `10_Projects/` (inside the project folder or alongside)
- New daily notes → `60_Calendar/` or as configured in Daily Notes plugin
- New meeting notes → `60_Calendar/` or inside project folders
- New person notes → `40_Network/`