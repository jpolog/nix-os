# Model Tier Routing & Agent Dashboard Implementation Guide

This guide shows how to use OMP's new cost optimization features.

## Overview

**Problem:** Using expensive models for cheap tasks wastes tokens.

**Solution:** Tier-based task routing + agent dashboard with intervention.

## Model Tiers (Already Configured)

Your `models.yml` has 4 tiers:

| Tier | Models | Cost | Best For |
|------|--------|------|----------|
| 1 - Frontier | DeepSeek V4 Pro, GLM-5.1 | $$$ | Architecture, planning, security |
| 2 - Balanced | GLM-5.1, Qwen3 Coder | $ | Day-to-day coding, debugging |
| 3 - Fast | Devstral Small, Nemotron | $ or FREE | Exploration, reads, quick edits |
| 4 - Multimodal | Gemini 3 Flash, Qwen3 VL | $$-$$$ | Vision, UI/UX, screenshots |

## Quick Start

### 1. View Current Model Assignment

```bash
/agent-view --models
```

Shows which model each agent is using:
```
┌─ codebase-explore (agent-1) ─┐
│ Model: devstral-small-2     │  ← Tier 3 (FREE)
│ Task: Find auth patterns    │
└─────────────────────────────┘

┌─ security-audit (agent-2) ──┐
│ Model: deepseek-v4-pro      │  ← Tier 1 ($$$)
│ Task: Audit auth system    │
└─────────────────────────────┘
```

### 2. Monitor Token Usage

```bash
/agent-view --tokens
```

Shows real-time token consumption:
```
┌─ codebase-explore (agent-1) ─┐
│ Tokens: 15,234               │
│ Task: Find auth patterns    │
│ Cost: $0.00 (free model)    │
└─────────────────────────────┘

┌─ security-audit (agent-2) ──┐
│ Tokens: 42,891              │
│ Task: Audit auth system    │
│ Cost: $0.07 (premium)      │
└─────────────────────────────┘
```

### 3. Intervene Mid-Task

When you see an agent exploring irrelevant files:

```bash
/agent-view
# Press 'i' to intervene

> Select agent: agent-1
> Enter message: Skip the logs/ directory, focus only on src/auth/

Agent acknowledges and adjusts course.
```

**Result:** 50-90% token savings by preventing drift.

## Cascading Agent Pattern

The optimal pattern for complex tasks:

### Step 1: Director Plans (Tier 1)

```bash
/plan "Audit authentication system for security vulnerabilities"
```

Director (DeepSeek V4 Pro):
- Analyzes task complexity
- Decomposes into subtasks
- Assigns workers based on task type
- Plans review strategy

**Cost:** ~5,000 tokens × $1.74/M = $0.009

### Step 2: Workers Execute (Tier 3)

Workers (Devstral Small):
- Explore codebase
- Read files
- Search for patterns
- Report findings

**Cost:** ~30,000 tokens × $0/M = $0.00 (FREE)

### Step 3: Director Reviews (Tier 1)

Director (DeepSeek V4 Pro):
- Synthesizes worker reports
- Makes final decisions
- Plans next steps

**Cost:** ~5,000 tokens × $1.74/M = $0.009

### Total Cost: $0.018 vs $0.14 (88% savings)

## Intervention Examples

### Example 1: Correcting Exploration Drift

**Without intervention:**
```
Worker (free): Exploring auth.js
Worker: Found 5 functions
Worker: Reading function 1...
Worker: Reading function 2...
Worker: Reading function 3...
Worker: Reading logs/auth.log...    ← Irrelevant!
Worker: Reading logs/error.log...    ← Irrelevant!
Worker: Reading logs/debug.log...    ← Irrelevant!
[Uses 50,000 tokens]
```

**With intervention:**
```
Worker: Exploring auth.js
Worker: Found 5 functions
Worker: Reading function 1...
Worker: Reading function 2...
User intervenes: "Skip logs/ directory, only check auth.js functions"
Worker: Acknowledged. Skipping logs/.
Worker: Reading function 3...
[Uses 15,000 tokens]
Savings: 70%
```

### Example 2: Narrowing Scope

**Without intervention:**
```
Worker: Searching for 'password'
Worker: Found 234 matches in entire codebase
Worker: Reading file 1/234...
Worker: Reading file 2/234...
[Will read all 234 files - massive token waste]
```

**With intervention:**
```
Worker: Searching for 'password'
Worker: Found 234 matches
User intervenes: "Only check src/auth/ and src/middleware/"
Worker: Filtering to src/auth/ and src/middleware/
Worker: Now have 12 files
[Uses 90% fewer tokens]
```

### Example 3: Preventing Redundancy

**Without intervention:**
```
Worker 1: Exploring src/auth/
Worker 2: Exploring src/auth/        ← Duplicate!
Worker 3: Exploring src/auth/        ← Duplicate!
[All 3 workers read the same files]
```

**With intervention:**
```
User sees dashboard showing duplicate work
User intervenes on Worker 2: "Worker 1 is already checking src/auth/"
User intervenes on Worker 3: "Worker 1 is already checking src/auth/"
Worker 2: Now checking src/middleware/
Worker 3: Now checking src/utils/
[No redundancy, optimal coverage]
```

## Configuration

### config.yml

```yaml
# Task routing configuration
taskRouting:
  auto: true  # Automatically route tasks to optimal models
  
  # Exploration uses fast/free models
  exploration:
    model: devstral-small-2
    maxTokens: 50000
    
  # Planning uses reasoning models
  planning:
    model: deepseek-v4-pro
    maxTokens: 100000
    
  # Execution uses balanced models
  execution:
    model: glm-5.1
    maxTokens: 50000
    
  # Quick tasks use ultra-fast models
  quick:
    model: rnj-1-8b
    maxTokens: 10000

# Agent dashboard configuration
agentView:
  enabled: true
  layout: tmux  # tmux-style split view
  showTokens: true
  showModels: true
  allowIntervention: true
  
# Director mode configuration
directorMode:
  enabled: true
  directorModel: deepseek-v4-pro
  workerModel: devstral-small-2
  reportBackOn:
    - drift-detected
    - token-limit-approached
    - user-intervention

# Model tier preferences
modelTiers:
  # Tier 1: Use for complex reasoning
  tier1:
    - architecture
    - security-audit
    - complex-planning
    - adversarial-analysis
    
  # Tier 2: Use for day-to-day coding
  tier2:
    - multi-file-edit
    - refactoring
    - debugging
    - api-design
    
  # Tier 3: Use for exploration
  tier3:
    - codebase-search
    - file-read
    - pattern-search
    - reference-find
    
  # Tier 4: Use for vision tasks
  tier4:
    - screenshot-analysis
    - ui-review
    - diagram-interpretation
    - accessibility-test
```

### Using the /plan Extension with Director Mode

```bash
/plan "Implement OAuth 2.0 authentication"
```

**What happens:**

1. **Director (DeepSeek V4 Pro)** analyzes task:
   - Decomposes into subtasks
   - Assigns optimal models to each subtask
   - Plans review strategy

2. **Workers (various models)** execute:
   - Exploration → Devstral Small (FREE)
   - Code generation → GLM-5.1 (FREE)
   - Security analysis → DeepSeek V4 Pro ($$$)

3. **Dashboard shows progress:**
   ```
   ┌─ Director (deepseek-v4-pro) ─┐
   │ Task: Plan OAuth 2.0        │
   │ Status: planning             │
   │ Tokens: 5,234                │
   └──────────────────────────────┘
   
   ├─ Worker 1 (devstral-small-2)
   │  Task: Explore auth patterns
   │  Status: running
   │  Tokens: 12,456
   │  
   ├─ Worker 2 (glm-5.1)
   │  Task: Generate OAuth code
   │  Status: waiting
   │  Tokens: 0
   │  
   └─ Worker 3 (deepseek-v4-pro)
      Task: Security review
      Status: waiting
      Tokens: 0
   ```

4. **You can intervene:**
   - See Worker 1 exploring logs/
   - Press 'i' to send message
   - Worker adjusts course

## Cost Comparison Examples

### Example 1: Security Audit

**Naive approach (everything with Tier 1):**
```
DeepSeek V4 Pro for everything
Total: 80,000 tokens × $1.74/M = $0.14
```

**Optimized approach:**
```
Worker (Devstral Small): Explore codebase
  → 30,000 tokens × $0/M = $0.00
Director (DeepSeek V4 Pro): Review findings
  → 10,000 tokens × $1.74/M = $0.017
Director: Plan fixes
  → 10,000 tokens × $1.74/M = $0.017
Worker (GLM-5.1): Execute fixes
  → 20,000 tokens × $0/M = $0.00
Total: $0.034

Savings: 76%
```

### Example 2: Documentation Generation

**Naive approach:**
```
DeepSeek V4 Pro for everything
Total: 50,000 tokens × $1.74/M = $0.087
```

**Optimized approach:**
```
Worker (Devstral Small): Explore code
  → 20,000 tokens × $0/M = $0.00
Worker (GLM-5.1): Generate docs
  → 30,000 tokens × $0/M = $0.00
Total: $0.00

Savings: 100% (FREE models sufficient)
```

### Example 3: Complex Refactoring

**Naive approach:**
```
DeepSeek V4 Pro for everything
Total: 100,000 tokens × $1.74/M = $0.174
```

**Optimized approach:**
```
Director (DeepSeek V4 Pro): Plan refactoring
  → 15,000 tokens × $1.74/M = $0.026
Worker (Devstral Small): Explore codebase
  → 30,000 tokens × $0/M = $0.00
Director (DeepSeek V4 Pro): Review plan
  → 10,000 tokens × $1.74/M = $0.017
Worker (GLM-5.1): Execute refactoring
  → 40,000 tokens × $0/M = $0.00
Director (DeepSeek V4 Pro): Final review
  → 5,000 tokens × $1.74/M = $0.009
Total: $0.052

Savings: 70%
```

## Best Practices

### DO:
- Use Tier 3 for exploration and reads
- Use Tier 1 for planning and architecture
- Use Tier 2 for coding and execution
- Intervene when workers drift
- Monitor token usage in real-time
- Compact conversation before director review

### DON'T:
- Use Tier 1 for file reads
- Use Tier 3 for security audits
- Let workers explore indefinitely
- Skip intervention opportunities
- Forget to compact before expensive operations

### Intervention Timing:

**Intervene early when:**
- Worker is exploring wrong directory
- Worker is reading irrelevant files
- Worker is about to perform expensive operation
- Multiple workers doing same task

**Don't intervene when:**
- Worker is making good progress
- Worker is synthesizing for director
- Worker is about to complete

## Troubleshooting

### Dashboard not showing agents

```bash
# Check if agents are running
/task-list

# If no agents, start a task
/plan "Your task here"
```

### Intervention not working

```bash
# Check agent status
/agent-view --models

# Ensure agent is not completed
/agent-view
# Only running agents accept interventions
```

### Token usage not updating

```bash
# Dashboard polls every 1 second
# Wait a moment for refresh

# Or force refresh
/agent-view --refresh
```

## Related Documentation

- [Model Tier Routing](model-tier-routing.md) - Theory and cost analysis
- [Compact Extension](../extensions/compact/README.md) - Conversation compaction
- [Plan Extension](../extensions/plan/README.md) - Director mode planning

## Future Enhancements

1. **Auto-pause on drift detection** - Pause agents when they drift
2. **Token budget alerts** - Notify before hitting limits
3. **Model switch mid-task** - Dynamically change model
4. **Cost prediction** - Estimate cost before starting
5. **Parallel agent view** - See all agents in real-time

## Support

For issues or questions:
- GitHub Issues: [oh-my-pi/issues]
- Documentation: [omp/docs]
- Community: [discord/oh-my-pi]