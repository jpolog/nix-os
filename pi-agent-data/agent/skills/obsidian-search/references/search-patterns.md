# Search Patterns Reference

Concrete command patterns for common vault operations. Adapt paths to the target vault.

## By Frontmatter Type

Find all notes of a specific type (concept, idea, project, etc.):

```
search pattern: "^type: concept$" path: "/home/jpolo/Vault/phd"
search pattern: "^type: idea$" path: "/home/jpolo/Vault/phd"
search pattern: "^type: project$" path: "/home/jpolo/Vault/phd"
search pattern: "^type: source/paper$" path: "/home/jpolo/Vault/phd"
search pattern: "^type: daily$" path: "/home/jpolo/Vault/phd"
search pattern: "^type: meeting$" path: "/home/jpolo/Vault/phd"
search pattern: "^type: person$" path: "/home/jpolo/Vault/phd"
search pattern: "^type: experiment$" path: "/home/jpolo/Vault/phd"
```

## By Status

```
# Active projects
search pattern: "^status: active$" path: "/home/jpolo/Vault/phd"

# Unread literature
search pattern: "^status: unread$" path: "/home/jpolo/Vault/phd"

# Reading
search pattern: "^status: reading$" path: "/home/jpolo/Vault/phd"

# Read
search pattern: "^status: read$" path: "/home/jpolo/Vault/phd"
```

## By Tag

```
# Frontmatter tags (YAML list format)
search pattern: "  - concept" path: "/home/jpolo/Vault/phd"
search pattern: "  - idea" path: "/home/jpolo/Vault/phd"
search pattern: "  - literature" path: "/home/jpolo/Vault/phd"
search pattern: "  - experiment" path: "/home/jpolo/Vault/phd"
search pattern: "  - network/person" path: "/home/jpolo/Vault/phd"
search pattern: "  - meeting" path: "/home/jpolo/Vault/phd"

# Inline tags
search pattern: "#concept" path: "/home/jpolo/Vault/phd"
search pattern: "#idea" path: "/home/jpolo/Vault/phd"
```

## By Author

```
# Find papers by author (in frontmatter)
search pattern: "^authors:.*Smith" path: "/home/jpolo/Vault/phd/20_Literature"
```

## By Date

```
# Find notes created on a specific date
search pattern: "^date_created: 2026-05-01$" path: "/home/jpolo/Vault/phd"

# Find notes created in a month
search pattern: "^date_created: 2026-04-" path: "/home/jpolo/Vault/phd"
```

## By Content

```
# Find all notes mentioning a term
search pattern: "reinforcement learning" path: "/home/jpolo/Vault/phd"

# Find all notes with TODO items
search pattern: "- \\[ \\]" path: "/home/jpolo/Vault/phd"

# Find all notes with specific callout types
search pattern: "> \\[!warning\\]" path: "/home/jpolo/Vault/phd"
search pattern: "> \\[!question\\]" path: "/home/jpolo/Vault/phd"

# Find notes with specific frontmatter fields
search pattern: "^relevance: high" path: "/home/jpolo/Vault/phd/20_Literature"
```

## By Folder

```
# List all notes in a specific folder
find pattern: "/home/jpolo/Vault/phd/20_Literature/*.md"
find pattern: "/home/jpolo/Vault/phd/30_Concepts/*.md"
find pattern: "/home/jpolo/Vault/phd/10_Projects/*.md"
```

## By Wikilinks (Backlinks)

```
# Find all notes linking to a specific note
search pattern: "\\[\\[Adaptive Instructional System" path: "/home/jpolo/Vault/phd"

# Find all notes linking to a person
search pattern: "\\[\\[Jane Smith" path: "/home/jpolo/Vault/phd"

# Find all notes linking to a project
search pattern: "\\[\\[AIED 2026" path: "/home/jpolo/Vault/phd"
```

## Orphan Notes

Notes with no inbound wikilinks. To check if a specific note is an orphan:

1. Get the note's title (filename without .md)
2. Search for `[[NoteTitle` across the entire vault
3. If no results, the note is an orphan

This is expensive for large vaults. Focus on specific folders.

## Recently Modified

```
# Find notes modified in the last 7 days
find pattern: "/home/jpolo/Vault/phd/**/*.md" (with mtime filter)
```

## Count Notes Per Folder

```
# Count markdown files in each numbered folder
find pattern: "/home/jpolo/Vault/phd/00_Inbox/*.md" (count results)
find pattern: "/home/jpolo/Vault/phd/10_Projects/*.md" (count results)
# etc.
```

## Empty Sections

Find notes with empty sections (potential gaps):

```
# Find concept notes with empty Intuition section
search pattern: "^## Intuition$" path: "/home/jpolo/Vault/phd/30_Concepts"
# Then check if the next line is also a heading (empty section)

# Find notes with "..." placeholder text
search pattern: "^\\.\\.\\.$" path: "/home/jpolo/Vault/phd"
```

## Full-Text Search Across Both Vaults

When searching both vaults simultaneously, clearly label results by vault:

```
search pattern: "query" path: "/home/jpolo/Vault/Knowledge Base, /home/jpolo/Vault/phd"
```