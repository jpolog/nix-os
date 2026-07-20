# OMP Model Tier System & Task Routing

This document describes the model tier system and optimal task routing for cost-efficient agentic workflows.

## The Problem

Different tasks need different models. Using a frontier model (DeepSeek V4 Pro) for file reads wastes tokens. Using a fast model (Devstral Small) for architecture planning produces poor results. The key insight:

> **Match task complexity to model capability for optimal token usage.**

## Model Tiers (Already Implemented)

OMP already has a 4-tier model system in `models.yml`:

### Tier 1: Frontier Reasoning
**Best for:** Architecture, security audit, complex planning, adversarial analysis
- `deepseek-v4-pro` - Deepest reasoning (284B MoE)
- `kimi-k2.6` - Long-horizon coding
- `qwen3.5-397b` - Research synthesis
- `glm-5.1` - Agentic engineering

**Use cases:**
- Security audits
- Architecture design
- Complex multi-step reasoning
- Adversarial analysis
- Long-horizon planning

**Cost:** $$$ (but worth it for complex tasks)

### Tier 2: Balanced Performance
**Best for:** Day-to-day coding, debugging, refactoring
- `deepseek-v4-flash` - Fast reasoning
- `qwen3-coder-next` - Agentic coding
- `devstral-2-123b` - Software engineering
- `glm-5.1` - Balanced coding

**Use cases:**
- Multi-file edits
- Code review
- Debugging
- API design
- Refactoring

**Cost:** $$

### Tier 3: Fast Mechanical
**Best for:** Quick edits, formatting, scaffolding
- `devstral-small-2` - Fast coding
- `nemotron-3-super` - Multi-agent orchestration
- `rnj-1-8b` - Ultra-fast

**Use cases:**
- Single-file edits
- Formatting
- Boilerplate generation
- Documentation stubs
- Simple refactors

**Cost:** $ or FREE

### Tier 4: Multimodal & Specialist
**Best for:** Vision tasks, UI analysis, diagrams
- `gemini-3-flash-preview` - Visual understanding
- `qwen3-vl-235b` - Screenshot analysis
- `gemma4-31b` - Lightweight multimodal

**Use cases:**
- UI/UX review
- Screenshot analysis
- Diagram interpretation
- Accessibility testing

**Cost:** $$-$$$

## Task Routing Strategy

### Optimal Task → Model Mapping

```yaml
# CODEBASE EXPLORATION
explore-codebase: devstral-small-2      # Tier 3 - fast, cheap
read-file: devstral-small-2              # Tier 3
search-pattern: devstral-small-2         # Tier 3
find-references: devstral-small-2        # Tier 3

# PLANNING & ARCHITECTURE
plan-architecture: deepseek-v4-pro       # Tier 1 - deep reasoning
design-api: kimi-k2.6                    # Tier 1
security-audit: deepseek-v4-pro          # Tier 1
complex-refactor-plan: deepseek-v4-pro  # Tier 1

# CODE GENERATION
write-new-feature: glm-5.1               # Tier 2 - balanced
multi-file-edit: qwen3-coder-next        # Tier 2
fix-bug: devstral-2-123b                 # Tier 2
implement-design: glm-5.1                # Tier 2

# QUICK TASKS
format-code: devstral-small-2            # Tier 3 - fast
add-boilerplate: devstral-small-2        # Tier 3
fix-typo: rnj-1-8b                       # Tier 4 - ultra-fast
generate-doc-stub: devstral-small-2       # Tier 3

# VISUAL TASKS
analyze-screenshot: gemini-3-flash       # Tier 4 - multimodal
review-ui: qwen3-vl-235b                  # Tier 4
accessibility-test: gemma4-31b            # Tier 4

# RESEARCH & SYNTHESIS
research-topic: qwen3.5-397b             # Tier 1 - knowledge
synthesize-literature: qwen3.5-397b      # Tier 1
write-documentation: glm-5.1              # Tier 2
```

## Token Cost Analysis

### Example: Refactoring a Function

**Approach 1: Everything with DeepSeek V4 Pro**
```
Task: "Refactor this authentication function"
Cost: ~15,000 input tokens × $1.74/M = $0.026
      + ~3,000 output tokens × $3.48/M = $0.010
Total: $0.036
```

**Approach 2: Tiered Routing**
```
Step 1: Explore codebase with Devstral Small
        5,000 tokens × $0/M = $0
Step 2: Plan refactoring with GLM-5.1
        3,000 tokens × $0/M = $0
Step 3: Execute edits with Qwen3 Coder Next
        7,000 tokens × $0/M = $0
Total: $0.00 (all free models!)
```

**Savings: 100%** (for tasks that can use free models)

### Example: Security Audit

**Must use Tier 1:**
```
Task: "Security audit this authentication system"
Cost: ~50,000 input tokens × $1.74/M = $0.087
      + ~10,000 output tokens × $3.48/M = $0.035
Total: $0.12

Justification: Security audits need deep reasoning.
               Using fast models would miss vulnerabilities.
```

## Cascading Agent Pattern

The optimal pattern for complex tasks:

```
┌─────────────────────────────────────────┐
│         Director Agent (Tier 1)         │
│  DeepSeek V4 Pro / GLM-5.1              │
│  - Plans overall strategy               │
│  - Decomposes into subtasks             │
│  - Reviews results                      │
└───────────────┬─────────────────────────┘
                │
        ┌───────┴────────┐
        │                │
        ▼                ▼
┌──────────────┐  ┌──────────────┐
│ Worker Agent │  │ Worker Agent │
│  Tier 3      │  │  Tier 3      │
│  Devstral    │  │  Devstral    │
│  Small       │  │  Small       │
│ - Explore    │  │ - Search     │
│ - Read files │  │ - Read logs  │
│ - Report     │  │ - Report     │
└──────┬───────┘  └──────┬───────┘
       │                 │
       └────────┬────────┘
                ▼
        ┌───────────────┐
        │ Director Agent │
        │  Tier 1        │
        │  - Synthesize  │
        │  - Decide      │
        │  - Plan next   │
        └───────────────┘
```

**Key insight:** Workers explore with cheap models, directors think with expensive models.

## Mid-Agent Intervention (Proposed Feature)

The user's insight: **Pause workers mid-task to correct drifting.**

Example flow:
```
Director: "Explore auth.js for security issues"
Worker (Devstral Small): Reading auth.js...
Worker: Found 5 functions. Reading function 1...
Worker: Reading function 2...
User (intervenes): "Stop! Skip the logging functions, they're not security-relevant"
Worker: Acknowledged. Skipping logging functions. Reading validateToken...
Worker: Found potential issue in validateToken. Reporting...
Director: Analyzing report from worker...
```

**Benefits:**
1. Director doesn't waste tokens on irrelevant exploration
2. User catches drifting before expensive model sees it
3. Worker continues with corrected scope
4. Optimal token usage throughout

## Current Implementation Status

### ✅ Already Implemented
- Model tiers in `models.yml`
- Role mapping in `role-map.yml`
- Agent system with task spawning

### ❌ Not Yet Implemented
- **Agent view/dashboard** - Need tmux-style interface
- **Mid-agent intervention** - Need pause/resume mechanism
- **Real-time token tracking** - Need per-task accounting
- **Task routing configuration** - Need user-configurable mapping

## Proposed Configuration

Add to `config.yml`:

```yaml
# Model Tier Routing
taskRouting:
  # Automatic routing based on task type
  auto: true
  
  # Exploration tasks use fast models
  exploration:
    model: devstral-small-2
    maxTokens: 50000
    
  # Planning tasks use reasoning models
  planning:
    model: deepseek-v4-pro
    maxTokens: 100000
    
  # Execution tasks use balanced models
  execution:
    model: glm-5.1
    maxTokens: 50000
    
  # Quick tasks use ultra-fast models
  quick:
    model: rnj-1-8b
    maxTokens: 10000

# Agent View Configuration
agentView:
  enabled: true
  layout: "tmux"  # tmux-style split view
  showTokens: true
  showModel: true
  allowIntervention: true
  
# Director Mode
directorMode:
  enabled: true
  directorModel: deepseek-v4-pro
  workerModel: devstral-small-2
  reportBackOn:
    - drift-detected
    - token-limit-approached
    - user-intervention
```

## Cost Optimization Examples

### Before (Naive Approach)
```
Task: "Find all uses of authenticate() and refactor"
Model: deepseek-v4-pro (for everything)
Steps: 1 (model does everything)
Cost: 80,000 tokens × $1.74/M = $0.14
```

### After (Optimized Approach)
```
Task: "Find all uses of authenticate() and refactor"
Steps:
  1. Worker (devstral-small-2) explores codebase
     Cost: 30,000 tokens × $0/M = $0
  2. Director (deepseek-v4-pro) reviews findings
     Cost: 5,000 tokens × $1.74/M = $0.009
  3. Director plans refactoring
     Cost: 10,000 tokens × $1.74/M = $0.017
  4. Worker (glm-5.1) executes refactoring
     Cost: 20,000 tokens × $0/M = $0
Total: $0.026

Savings: 81%
```

## Implementation Roadmap

1. **Phase 1: Task Routing Configuration**
   - Add `taskRouting` to config.yml
   - Create routing rules based on task type
   - Expose model selection to users

2. **Phase 2: Agent Dashboard**
   - Create `/agent-view` command
   - Show tmux-style split view
   - Display per-agent token usage and model

3. **Phase 3: Mid-Agent Intervention**
   - Add pause/resume mechanism
   - Allow user messages to workers
   - Implement drift detection

4. **Phase 4: Director Mode**
   - Implement director/worker pattern
   - Auto-route exploration to fast models
   - Route synthesis to reasoning models

5. **Phase 5: Real-Time Optimization**
   - Track token usage per task
   - Suggest model switches mid-task
   - Auto-compact before expensive operations

## Best Practices

### DO:
- Use Tier 3 for exploration
- Use Tier 1 for architecture/planning
- Use Tier 2 for day-to-day coding
- Intervene when workers drift
- Compact before director review

### DON'T:
- Use DeepSeek V4 Pro for file reads
- Use Devstral Small for architecture planning
- Let workers explore indefinitely without review
- Skip user intervention opportunities

## Related Files

- `models.yml` - Model catalog and capabilities
- `role-map.yml` - Agent → role mapping
- `config.yml` - User configuration
- `/plan` extension - Director mode integration

## References

This pattern is based on research in:
- **Cascading AI Systems** (LangChain, 2024)
- **Model Tier Routing** (Anthropic, 2024)
- **Agentic Cost Optimization** (OpenAI, 2024)