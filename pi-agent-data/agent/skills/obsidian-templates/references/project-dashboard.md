---
type: project
status: active
deadline: ""
tags: [project]
date_created: {{DATE}}
---
# Project: {{TITLE}}

## Objective
-

## Literature Review
```dataview
TABLE authors, year, relevance, status
FROM "20_Literature"
WHERE contains(related_projects, this.file.link)
SORT relevance DESC
```

## Experiments
```dataview
TABLE status, hyperparams.lr as "LR", hyperparams.batch_size as "Batch", model_type
FROM "10_Projects"
WHERE type = "experiment" AND contains(project, this.file.link)
SORT file.name DESC
```

## Related Concepts
```dataview
LIST
FROM "30_Concepts"
WHERE contains(file.outlinks, this.file.link)
```

## Tasks
- [ ]

## Timeline

| Milestone | Target Date | Status |
| :--- | :--- | :--- |
| | | |

## Notes
-