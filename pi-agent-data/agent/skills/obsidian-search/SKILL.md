---
name: obsidian-search
description: Search, query, navigate, and perform bulk operations on Obsidian vaults. Use when finding notes by title, tag, frontmatter, content, or link structure; when traversing the link graph; when performing bulk operations like retagging, renaming, or moving notes.
globs:
  - "**/*.md"
alwaysApply: false
---

# Obsidian Search

Find, query, and manipulate notes across Obsidian vaults using filesystem tools.

## Vaults

| Vault | Path |
|---|---|
| Knowledge Base | `/home/jpolo/Vault/Knowledge Base` |
| PhD | `/home/jpolo/Vault/phd` |

By default, search both vaults. Narrow to one when the user specifies.

## Finding Notes by Title

Use `find` with glob patterns. Obsidian note titles come from filenames (without `.md`):

```bash
# Find by exact title
find "/home/jpolo/Vault/phd" -name "Adaptive Instructional System (AIS).md"

# Find by partial title
find "/home/jpolo/Vault/phd" -name "*adaptive*.md"
```

## Finding Notes by Tag

Use `search` for inline tags (`#tag`) or frontmatter `tags:` fields:

```
# Find all notes with #concept tag
search pattern: "^tags:.*concept" in phd vault

# Find inline tags
search pattern: "#concept" in phd vault
```

## Finding Notes by Frontmatter Field

Use `search` to match YAML frontmatter fields. Frontmatter is between `---` delimiters at the top of the file:

```
# Find all notes with type: concept
pattern: "^type: concept$"

# Find all active projects
pattern: "^status: active$"

# Find all papers by a specific author
pattern: "^authors:.*Smith"

# Find all unread literature
pattern: "^status: unread$"
```

## Finding Notes by Content

Use `search` for body text searches within vault directories:

```
# Find notes mentioning "reinforcement learning"
pattern: "reinforcement learning" in 20_Literature/

# Find notes with TODO items
pattern: "- \[ \]"

# Find notes with specific callout types
pattern: "> \\[!warning\\]"
```

## Finding Backlinks

To find all notes that link TO a specific note, search for `[[NoteTitle]]`:

```
# Find all notes linking to "Adaptive Instructional System (AIS)"
pattern: "\\[\\[Adaptive Instructional System"

# Find all notes linking to a concept
pattern: "\\[\\[Reinforcement Learning"
```

## Finding Orphan Notes

A note is an orphan if no other note links to it. To find orphans:

1. List all note titles in the vault
2. For each title, search for `[[title]]` across the vault
3. If no results, the note is an orphan

This is expensive for large vaults. Focus on specific folders for efficiency.

## Bulk Operations

### Renaming a Note

When renaming a note, all wikilinks pointing to it must also be updated:

1. Rename the file
2. Search for all `[[OldName]]` and `[[OldName|` across the vault
3. Replace with `[[NewName]]` and `[[NewName|` respectively

### Moving a Note Between Folders

1. Move the file to the new folder
2. Verify wikilinks still resolve (Obsidian resolves by filename, so links still work)
3. Update any explicit folder references in frontmatter if needed

### Retagging

To change or add tags:

1. Edit the `tags:` field in frontmatter
2. For inline tags, search and replace `#oldtag` with `#newtag`
3. Verify no broken references

### Updating Frontmatter Fields

1. Read the file
2. Edit the specific YAML field
3. Validate the YAML remains valid

## Cross-Vault Search

Both vaults can be searched simultaneously:

```
# Search both vaults
find "/home/jpolo/Vault/Knowledge Base" "/home/jpolo/Vault/phd" -name "*.md" ...
search pattern: "query" in both paths
```

When results span both vaults, clearly label which vault each result belongs to.

## Dataview Queries

Dataview queries appear in templates as code blocks:

```dataview
TABLE authors, year, relevance, status
FROM "20_Literature"
WHERE contains(related_projects, this.file.link)
SORT relevance DESC
```

These are rendered by the Obsidian Dataview plugin at display time. The agent should NOT try to execute them. Instead, use filesystem tools to achieve similar results:

- `FROM "20_Literature"` → `find` in the `20_Literature/` folder
- `WHERE contains(authors, "Smith")` → `search` for `authors:.*Smith` in frontmatter
- `WHERE type = "concept"` → `search` for `^type: concept$` in frontmatter
- `SORT file.name ASC` → sort results alphabetically by filename

See [dataview-queries.md](references/dataview-queries.md) for common query patterns and their filesystem equivalents.

## Search Strategies

For detailed search patterns with concrete examples, see [search-patterns.md](references/search-patterns.md).