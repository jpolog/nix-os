---
type: lab
tags: [lab]
date_created: {{DATE}}
---
# {{TITLE}}

## Lab Overview
(What is this lab? Focus areas, research group)

## Key People
```dataview
TABLE role, expertise
FROM "40_Network"
WHERE contains(affiliation, this.file.link)
SORT role ASC
```

## Active Projects
```dataview
TABLE status, deadline
FROM "10_Projects"
WHERE type = "project" AND status = "active"
SORT deadline ASC
```

## Resources
- **Compute:** 
- **Datasets:** 
- **Equipment:** 

## Notes
-