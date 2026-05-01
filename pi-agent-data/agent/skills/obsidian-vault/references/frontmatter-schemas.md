# Frontmatter Schemas Reference

Schemas for each note type across both vaults. Required fields are marked; all others are optional.

## PhD Vault Schemas

### Concept Note (`type: concept`)

```yaml
---
type: concept
aliases: []           # List of alternative names
tags:
  - concept
date_created: YYYY-MM-DD  # ISO date
---
```

Sections: Formal Definition, Intuition, Implementation (code block), Relations (wikilinks), Flashcards (Q&A with spaced repetition), References (dataview query).

### Research Idea (`type: idea`)

```yaml
---
type: idea
status: idea          # idea | hypothesis | testing | validated | abandoned
confidence: low       # low | medium | high
tags: [idea]
related_concepts: []  # List of [[wikilinks]]
related_projects: []  # List of [[wikilinks]]
date_created: YYYY-MM-DD
---
```

Sections: The Question, The Gap, Proposed Method (numbered steps), Expected Outcome, Feasibility (Compute/Data/Timeline), Context (Supports/Contradicts/Inspired by wikilinks).

### Project Dashboard (`type: project`)

```yaml
---
type: project
status: active        # active | on-hold | completed | abandoned
deadline: ""          # ISO date or empty
tags: [project]
date_created: YYYY-MM-DD
---
```

Sections: Objective, Literature Review (dataview TABLE), Experiments (dataview TABLE), Related Concepts (dataview LIST), Tasks (checkbox list), Timeline (markdown table), Notes.

### Zotero Import / Literature Note (`type: source/paper`)

```yaml
---
citekey: "{{citekey}}"
type: source/paper
status: unread        # unread | reading | read | reviewed | cited
relevance:            # high | medium | low
tags:
  - literature
  - topic/...         # Topic tags from Zotero
authors: "{{authors}}"
year: YYYY
publication: "{{publicationTitle}}"
doi: "{{DOI}}"
url: "{{url}}"
aliases:
  - "{{title}}"
  - "@{{citekey}}"
related_projects:
date_created: YYYY-MM-DD
---
```

Sections: Meta (Zotero link, PDF link, authors, venue, DOI, URL), Abstract, Key Contributions, Methodology & Architecture, Results (metrics table), Limitations & Research Gaps, Connection to My Work (wikilinks), Extracted Annotations (color-coded callouts by Zotero highlight color).

Zotero annotation color mapping:
- `#a28ae5` (purple) → Objectives & Abstracts `[!abstract]`
- `#ffd400` (yellow) → Key Findings `[!warning]`
- `#5fb236` (green) → Methodology `[!success]`
- `#2ea8e5` (blue) → Related Work `[!info]`
- `#f19837` (orange) → Definitions & Questions `[!question]`
- `#ff6666` (red) → Critique & Limitations `[!failure]`

### Daily Note (`type: daily`)

```yaml
---
date: YYYY-MM-DD
type: daily
tags: [log/daily]
---
```

Sections: Deadline Watch (dynamically computed table with days remaining), Research Intention, Interstitial Log (timestamped), Active Experiments (dataview), Tasks Due Today (tasks query), Meetings, Quick Capture.

### Meeting (`type: meeting`)

```yaml
---
date: YYYY-MM-DD
type: meeting
participants: ["[[]]"]   # List of person wikilinks
project: "[[]]"          # Project wikilink
tags: [meeting]
---
```

Sections: Agenda (numbered list), Discussion Notes, Action Items (checkboxes with @person), Follow-up (next meeting date, linked note).

### Person (`type: person`)

```yaml
---
type: person
role: ""                 # e.g., "Supervisor", "Collaborator"
affiliation: "[[]]"      # Lab or institution wikilink
aliases: []
website: ""
scholar_profile: ""
twitter: ""
email: ""
expertise: []
tags: [network/person]
status: prospective_collaborator  # prospective_collaborator | active_collaborator | advisor | student
date_created: YYYY-MM-DD
---
```

Sections: Expertise & Interests (wikilinks), Affiliation (lab, institution, position, relation), Bibliography (dataview TABLE from 20_Literature where author matches), Interaction Log (dated entries).

### Experiment Log (`type: experiment`)

```yaml
---
type: experiment
experiment_id: EXP-YYYYMMDD-HHMM
status: in-progress     # in-progress | completed | failed | abandoned
project: "[[]]"
model_type: ""
dataset: "[[]]"
hyperparams:
  lr: 3e-4
  batch_size: 32
  optimizer: AdamW
  scheduler: CosineAnnealing
  epochs: 100
  dropout: 0.1
tags: [experiment]
date_created: YYYY-MM-DD
---
```

Sections: Hypothesis/Goal, Configuration (code branch, commit hash, command, compute node, GPU, runtime), Execution Log (timestamped), Results (metrics table: Train Loss, Val Loss, Test Acc), Figures, Conclusion & Next Steps (checkbox).

### Dataset (`type: dataset`)

```yaml
---
type: dataset
tags: [dataset]
date_created: YYYY-MM-DD
---
```

### Lab (`type: lab`)

```yaml
---
type: lab
tags: [lab]
date_created: YYYY-MM-DD
---
```

### Student (`type: student`)

```yaml
---
type: student
tags: [student]
date_created: YYYY-MM-DD
---
```

---

## Knowledge Base Schema

### Book Note (using book-template)

```yaml
---
status: To Read          # To Read | Reading | Read | Reviewed
title: "{{title}}"
subtitle: "{{subtitle}}"
description: "{{description}}"
categories: [{{category}}]
authors: [{{author}}]
published_on: {{publishDate}}
publisher: {{publisher}}
pages: {{totalPage}}
isbn: {{isbn10}}
cover: {{coverUrl}}
local_cover: {{localCoverImage}}
tags:
  - book_notes
  - books
  - summaries
---
```

Sections: Book Information (two-column table with cover image), Description, Key Quotes, Key Ideas, Chapters.