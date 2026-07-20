# How Model Delegation Actually Works

## The Core Question

**Can GLM-5 (main model) spawn `explore` (cheap model) using the `task` tool?**

**Answer: YES, but with important constraints.**

## How It Works

### 1. The `task` Tool is Available to Models

The `task` tool is in the INVENTORY - this means **any model can use it**:

```
Spawns subagents to work in the background — one per `tasks[]` item
- `agent`: agent type to spawn
- `context`: shared background prepended to every assignment
- `tasks`: tasks to spawn — one subagent per item
```

### 2. Built-in Agents Use Model Roles

Built-in agents (`explore`, `task`, `plan`, `oracle`, `designer`, `reviewer`, `librarian`, `quick_task`) are **NOT** in `agents/*.md`. They use the model roles from `config.yml`:

```yaml
modelRoles:
  default: ollama-cloud/glm-5              # Default model
  smol: ollama/devstral-small-2:24b-cloud  # Cheap/fast model
  slow: ollama/glm-5.1:cloud               # Deep reasoning
  plan: ollama/glm-5.1:cloud               # Planning
```

**What this means:**
- `explore` → uses `smol` role → `devstral-small-2:24b-cloud` (cheap!)
- `quick_task` → uses `smol` role → `devstral-small-2:24b-cloud` (cheap!)
- `plan` → uses `plan` role → `glm-5.1:cloud`
- `task` → uses `default` role → `glm-5` (same as main)
- `oracle` → uses `slow` role → `glm-5.1:cloud`

### 3. Custom Agents Have Fixed Models

Custom agents in `agents/*.md` have fixed model assignments:

```yaml
---
name: lang-python-pro
model: ollama/qwen3-coder-next:cloud  # FIXED - cannot change
---
```

**These do NOT use model roles - they have hardcoded models.**

## The Actual Behavior

### Scenario: GLM-5 Decides to Explore

**User says:** "Find all authentication bugs in the codebase"

**GLM-5 can:**

```
Option 1: Do it itself (expensive)
- Uses `read`, `search`, `grep` tools directly
- Model: glm-5 (expensive, slow)
- Tokens: ALL counted against glm-5

Option 2: Spawn explore agent (cheap)
- Uses `task` tool with agent: "explore"
- Model: devstral-small-2:24b-cloud (cheap, fast)
- Tokens: Explore's tokens counted against devstral-small-2
- GLM-5 only sees the summary result
```

**GLM-5 will choose Option 2 if:**
1. It recognizes the task is "exploration" (reading files, searching)
2. It wants to save tokens/cost
3. The task can be parallelized

### How GLM-5 Knows Which Agent to Use

**The INVENTORY section in the system prompt tells it:**

```
# explore — READ-ONLY (no edit/write/exec tools)
Fast read-only codebase scout returning compressed context for handoff
```

**The model sees:**
- `explore` is for exploration
- `quick_task` is for mechanical updates
- `task` is for general work
- `plan` is for architecture
- `oracle` is for complex decisions
- `designer` is for UI/UX
- `reviewer` is for code review
- `librarian` is for external research

**The model does NOT see the model roles directly, but it can infer:**
- `explore` and `quick_task` are described as "fast" → cheap models
- `plan` and `oracle` are described as "architect", "senior engineer" → expensive models

## What the Model CAN and CANNOT Control

### ✅ CAN Control

1. **Which agent type to spawn:**
   ```
   task(agent: "explore", context: "Find auth patterns", tasks: [...])
   ```
   GLM-5 chooses `explore` → cheap model automatically

2. **What task to give:**
   ```
   task(agent: "quick_task", assignment: "Fix typos in README")
   ```
   GLM-5 chooses `quick_task` → cheap model automatically

3. **Whether to spawn at all:**
   - Do it itself (expensive)
   - Delegate to subagent (cheap if explore/quick_task)

### ❌ CANNOT Control

1. **Which model the subagent uses:**
   - If agent is `explore` → model is `devstral-small-2` (hardcoded via role)
   - If agent is `lang-python-pro` → model is `qwen3-coder-next` (hardcoded in frontmatter)
   - Cannot override: `task(agent: "explore", model: "deepseek-v4-pro")` ← INVALID

2. **Model roles:**
   - Cannot change `smol` → different model
   - Cannot change `default` → different model
   - These are configured in `config.yml` by the user, not the model

3. **Custom agent models:**
   - Cannot change `lang-python-pro` to use a different model
   - Must use the model defined in `agents/lang-python-pro.md`

## The Intelligence is in Agent Selection

GLM-5 is smart enough to know:

**"This is an exploration task → spawn `explore` → automatically uses cheap model"**

**"This is a complex refactoring → do it myself with `edit` tool → uses my model (glm-5)"**

**"This is a quick mechanical fix → spawn `quick_task` → automatically uses cheap model"**

**"This is an architecture decision → spawn `plan` → uses planning model"**

## Verification

To see this in action, check a session where GLM-5 spawned agents:

```bash
# Look for task tool usage
grep -B2 -A5 "task.*agent" pi-agent-data/agent/sessions/<latest>/context.md

# You'll see something like:
# Main: "I'll use the explore agent to efficiently search the codebase"
# Tool use: task(agent: "explore", ...)
# Result: explore agent ran with devstral-small-2
```

## Summary

| Aspect | Who Controls It |
|--------|----------------|
| Which agent to spawn | GLM-5 (main model) |
| What task to give | GLM-5 (main model) |
| Whether to spawn | GLM-5 (main model) |
| Which model agent uses | **HARDCODED** (model roles or frontmatter) |
| Model role definitions | User (in `config.yml`) |
| Custom agent models | User (in `agents/*.md` frontmatter) |

**The routing is:**
- Intelligent at the **task level** (GLM-5 chooses appropriate agent)
- Fixed at the **model level** (agent → model is hardcoded)

**This means:**
- GLM-5 CAN delegate to cheap models by choosing appropriate agents
- GLM-5 CANNOT change which model an agent uses
- User configures which models each agent type uses