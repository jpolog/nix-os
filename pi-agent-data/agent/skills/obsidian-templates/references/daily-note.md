---
date: {{DATE}}
type: daily
tags: [log/daily]
---
# Daily Log: {{DATE}}

<< [[{{YESTERDAY}}]] | [[{{TOMORROW}}]] >>

## Deadline Watch
(Manually update or use a Dataview query to track upcoming deadlines)

## Research Intention
-

## Interstitial Log
- **{{TIME}}** -

## Active Experiments
```dataview
TABLE status, project
FROM "10_Projects"
WHERE type = "experiment" AND (status = "running" OR status = "in-progress")
SORT file.ctime DESC
```

## Tasks Due Today
```tasks
not done
due on or before {{DATE}}
```

## Meetings
-

## Quick Capture
-