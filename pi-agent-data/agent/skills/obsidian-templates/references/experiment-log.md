---
type: experiment
experiment_id: EXP-{{TIMESTAMP}}
status: in-progress
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
date_created: {{DATE}}
---
# Exp: {{TITLE}}

## Hypothesis / Goal
-

## Configuration
- **Code Branch:** `feat/`
- **Commit Hash:**
- **Command:** `python train.py --config configs/.yaml`
- **Compute Node:**
- **GPU:**
- **Estimated Runtime:**

## Execution Log
- **{{TIME}}**: Run started.

## Results

| Metric | Value |
| :--- | :--- |
| Train Loss | |
| Val Loss | |
| Test Acc | |

## Figures
(Paste training curves, confusion matrices, etc.)

## Conclusion & Next Steps
- [ ] Experiment Failed / Succeeded
- **Observation:**
- **Action:** [[]]