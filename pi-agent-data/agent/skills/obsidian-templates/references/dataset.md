---
type: dataset
tags: [dataset]
date_created: {{DATE}}
---
# {{TITLE}}

## Description
(What is this dataset? Source, format, size)

## Location
(Where is it stored? Path, URL, or reference)

## Schema
(Columns/fields, types, units)

## Statistics
(Record count, label distribution, missing values)

## Preprocessing
(What transformations were applied?)

## Related Experiments
```dataview
TABLE status, experiment_id
FROM "10_Projects"
WHERE contains(dataset, this.file.link)
SORT file.name DESC
```