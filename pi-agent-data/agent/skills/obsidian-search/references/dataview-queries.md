# Dataview Queries Reference

How the Dataview plugin queries work in vault templates, and their filesystem search equivalents.

## How Dataview Works

Dataview is an Obsidian plugin that provides a query language for vault data. Queries appear in code blocks:

````markdown
```dataview
TABLE authors, year, relevance, status
FROM "20_Literature"
WHERE contains(related_projects, this.file.link)
SORT relevance DESC
```
````

These queries are **rendered by the Obsidian plugin at display time**. The agent should NOT try to execute them. Instead, use filesystem search tools to achieve similar results.

## Dataview Query Language

### TABLE Queries

Display a table of notes with specific columns:

```dataview
TABLE column1, column2, column3
FROM "folder"
WHERE condition
SORT column ASC
```

### LIST Queries

Display a simple list of notes:

```dataview
LIST
FROM "folder"
WHERE condition
SORT file.name ASC
```

### FROM Clause

Specifies which notes to include:
- `FROM "folder"` — notes in a specific folder
- `FROM #tag` — notes with a specific tag
- `FROM [[]]` — notes that link to the current note
- `FROM "folder" AND #tag` — combination

### WHERE Conditions

- `contains(field, value)` — field contains value
- `field = value` — exact match
- `field > value` — comparison
- `type = "concept"` — match frontmatter type
- `status = "active"` — match frontmatter status
- `contains(file.outlinks, this.file.link)` — notes that the current note links to
- `contains(authors, "Smith")` — match frontmatter list field

### SORT

- `SORT file.name ASC` — alphabetical by name
- `SORT date_created DESC` — newest first
- `SORT relevance DESC` — by custom field

## Template Queries and Their Filesystem Equivalents

### Project Dashboard — Literature Review

```dataview
TABLE authors, year, relevance, status
FROM "20_Literature"
WHERE contains(related_projects, this.file.link)
SORT relevance DESC
```

**Filesystem equivalent**: Find all notes in `20_Literature/` that contain the project name in their `related_projects` frontmatter field.

### Project Dashboard — Experiments

```dataview
TABLE status, hyperparams.lr as "LR", hyperparams.batch_size as "Batch", model_type
FROM "10_Projects"
WHERE type = "experiment" AND contains(project, this.file.link)
SORT file.name DESC
```

**Filesystem equivalent**: Find all notes in `10_Projects/` with `type: experiment` in frontmatter and the project name in their `project` field.

### Project Dashboard — Related Concepts

```dataview
LIST
FROM "30_Concepts"
WHERE contains(file.outlinks, this.file.link)
```

**Filesystem equivalent**: Find all notes in `30_Concepts/` that contain `[[ProjectName]]` in their body.

### Person — Bibliography

```dataview
TABLE year, status, relevance
FROM "20_Literature"
WHERE contains(authors, this.file.name)
SORT year DESC
```

**Filesystem equivalent**: Find all notes in `20_Literature/` where the `authors` frontmatter field contains the person's name.

### Daily Note — Active Experiments

```dataview
TABLE status, project
FROM "10_Projects"
WHERE type = "experiment" AND (status = "running" OR status = "in-progress")
SORT file.ctime DESC
```

**Filesystem equivalent**: Find all notes in `10_Projects/` with `type: experiment` and `status: running` or `status: in-progress`.

### Concept Note — References

```dataview
LIST
FROM [[]] AND #literature
SORT file.name ASC
```

**Filesystem equivalent**: Find all notes that contain `[[ConceptName]]` in their body AND have `#literature` tag.

## Common Operations Cheat Sheet

| Dataview Query | Filesystem Equivalent |
|---|---|
| `FROM "20_Literature"` | `find` in `20_Literature/` |
| `WHERE type = "concept"` | `search` for `^type: concept$` |
| `WHERE status = "active"` | `search` for `^status: active$` |
| `WHERE contains(authors, "Smith")` | `search` for `^authors:.*Smith` |
| `WHERE contains(file.outlinks, this.file.link)` | `search` for `[[NoteTitle` |
| `WHERE contains(related_projects, this.file.link)` | `search` for `[[NoteTitle` in frontmatter `related_projects` field |
| `SORT file.name ASC` | Alphabetical sort of filenames |
| `SORT date_created DESC` | Sort by `date_created` frontmatter field |
| `FROM #literature` | `search` for `#literature` or frontmatter `tags:.*literature` |