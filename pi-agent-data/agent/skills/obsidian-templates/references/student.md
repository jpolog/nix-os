---
type: student
tags: [student]
date_created: {{DATE}}
---
# {{TITLE}}

## Student Info
- **Program:** 
- **Year:** 
- **Advisor:** [[]]
- **Research Interest:** 

## Courses
- 

## Projects
```dataview
TABLE status, deadline
FROM "10_Projects"
WHERE contains(file.outlinks, this.file.link)
SORT status ASC
```

## Meetings
```dataview
LIST
FROM "60_Calendar"
WHERE type = "meeting" AND contains(participants, this.file.link)
SORT date DESC
```

## Notes
-