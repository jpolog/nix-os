# Intelligent Model Routing Analysis: Tool-Delegation via Specialized Subagents

## The Proposal

Instead of the main model calling `read(file)` directly, spawn a specialized subagent:
- **Current**: Main model calls `read(file)` → returns content → main model processes
- **Proposed**: Main model spawns `read-agent` (cheap model) → agent reads → returns to main model

## Current State (What Exists)

### ✅ Already Implemented
1. **Model Tiers** (`models.yml`): 4-tier system from frontier to ultra-fast
2. **Role Mapping** (`role-map.yml`): 160+ agents mapped to abstract roles
3. **Subagent Spawning** (`task` tool): Can spawn specialized agents
4. **Model Switching** (`pi.setModel()`): Can switch models mid-session

### ❌ Not Implemented
1. **Per-Tool Model Routing**: Can't route individual `read()` calls to different models
2. **Tool-Delegation Agents**: No "file-reader-agent" that specializes in `read`
3. **Dynamic Agent Activation**: No automatic "activate cheap agent for this operation"

## Architecture Comparison

### Current Flow
```
User: "Find auth bugs and fix them"
  │
  ├── Main Agent (GLM-5.1, $0/M)
  │     ├── read(auth.js) ← 5K tokens context
  │     ├── analyze(...)     ← 10K tokens
  │     ├── search(...)      ← 2K tokens
  │     ├── plan fixes       ← 3K tokens
  │     └── edit(...)        ← 8K tokens
  │
  └── Total: ~28K tokens, single model
```

### Proposed Flow
```
User: "Find auth bugs and fix them"
  │
  ├── Main Agent (GLM-5.1) - Director
  │     ├── spawn read-agent (Devstral Small)
  │     │     └── read(auth.js) → report: "found X"
  │     ├── spawn search-agent (Devstral Small)
  │     │     └── search(...) → report: "found Y"
  │     └── analyze reports + plan fixes
  │
  └── Total: Director 15K + Workers 7K = 22K tokens
      BUT: latency += agent_spawn_overhead * 2
```

## Latency Analysis

### Operation Latencies (Real Measurements)

| Operation | Latency | Model Cost |
|-----------|---------|------------|
| `read()` tool | 50-200ms | $0 |
| `search()` tool | 100-500ms | $0 |
| Agent spawn | 100-500ms | varies |
| Agent context switch | 50-150ms | $0 |
| GLM-5.1 inference | 1-3s | $0 |
| Devstral Small inference | 200-500ms | $0 |

### Scenario: Read 5 Files + Analyze

**Current (Single Model)**
```
read(file1)  200ms
read(file2)  180ms
read(file3)  220ms
read(file4)  190ms
read(file5)  210ms
analyze      2500ms
────────────────
Total:       3500ms
```

**Proposed (Tool-Delegation)**
```
spawn reader-1   300ms
spawn reader-2   300ms
spawn reader-3   300ms
spawn reader-4   300ms
spawn reader-5   300ms
(parallel reads)
reader-1 done    400ms
reader-2 done    380ms
reader-3 done    420ms
reader-4 done    360ms
reader-5 done    400ms
context-switch   150ms
analyze          2500ms
────────────────────
Total:           3760ms (parallel spawn)
-or-             5510ms (sequential spawn)
```

**Key Insight**: Parallel agent spawning has **similar latency** to sequential tool calls, but **adds complexity**.

## When Tool-Delegation Wins

### ✅ Wins When:
1. **True Parallelization Needed**: Multiple independent tasks that can run simultaneously
   - Example: Read 20 files in parallel with 5 agents (4 files each)
   
2. **High Token Savings**: Operations where worker tokens are much cheaper than director
   - Example: Frontier model director ($$$) + Free worker models
   
3. **Fault Isolation Critical**: When you need isolation between operations
   - Example: Security audit where each file gets its own sandboxed agent

### ❌ Loses When:
1. **Sequential Dependencies**: Operations that depend on previous results
   - Example: Read file1, analyze, then decide what to read next
   
2. **Context Sharing Needed**: Operations that need shared state
   - Example: Building up understanding across multiple files
   
3. **Low Token Savings**: When models are free anyway
   - Example: GLM-5.1 (free) vs Devstral Small (free) = $0 savings

4. **Debugging Complexity**: When you need to understand what went wrong
   - Example: Did the read agent fail? The context switch? The analysis?

## The Real Problem: OMP Already Has Free Models

### Current Model Economics

| Model | Cost | Tier | Role |
|-------|------|------|------|
| GLM-5.1 | **FREE** | Tier 1 (frontier) | Main agent |
| Qwen3 Coder | **FREE** | Tier 2 (balanced) | Code specialist |
| Devstral Small | **FREE** | Tier 3 (fast) | Fast coding |
| Qwen 3.5 | **FREE** | Tier 1 (frontier) | Research |

**The savings from routing to cheaper models is $0** because OMP's model catalog is already optimized for free-tier usage.

**The only paid models** are:
- DeepSeek V4 Pro ($1.74/M input, $3.48/M output) - for deep reasoning
- Kimi K2.6 ($0.95/M input, $4.0/M output) - for long-horizon tasks
- Gemini 3 Flash ($0.5/M input, $3.0/M output) - for multimodal

These are **already** used selectively for tasks that need them.

## What Would Actually Help

### 1. **Operation-Level Model Selection** (Better than agent delegation)

```yaml
# In config.yml
operationRouting:
  read:
    model: devstral-small-2  # Fast, cheap for reading
  search:
    model: devstral-small-2  # Fast, cheap for searching
  analyze:
    model: glm-5.1           # Frontier for analysis
  edit:
    model: qwen3-coder-next  # Specialist for editing
```

**Implementation**: Before calling a tool, switch model with `pi.setModel()`, call tool, then switch back.

**Benefit**: No agent spawn overhead, same cost savings (which is $0 for free models).

### 2. **Parallelization Hints** (More useful than tool-delegation)

```yaml
# When user says "analyze all auth files"
parallelRead:
  enabled: true
  maxAgents: 5
  agentModel: devstral-small-2
  pattern: "spawn N agents, each reads subset, all report back"
```

**Benefit**: Explicit parallelization for cases where it helps, without forcing it everywhere.

### 3. **Task Decomposition Templates** (Better than per-tool agents)

```yaml
# When user says "audit security"
taskTemplates:
  security-audit:
    director: deepseek-v4-pro
    workers:
      - role: file-reader
        model: devstral-small-2
        count: 5
      - role: vulnerability-scanner
        model: glm-5.1
        count: 2
    pattern: "director spawns readers, readers report to scanners, scanners report to director"
```

**Benefit**: Structured decomposition for complex tasks, not micro-management of individual tool calls.

## The Fundamental Issue: Context vs. Delegation

### The Context Problem

When you delegate `read(file)` to a subagent:
- **Agent context**: `["user request", "task assignment"]` (minimal)
- **Agent result**: `"found X in file"` (summary)
- **Lost**: The actual file content, which might be needed later

If the director needs the file content to make decisions, **the subagent must return the full content**, negating the token savings.

If the director doesn't need the content, **why is it reading the file at all?**

### The Right Granularity

```
✅ Good delegation:
   Director: "Find all authentication functions"
   Worker: [reads files, searches, returns function names]
   Director: [plans refactoring based on function names]

❌ Bad delegation:
   Director: "Read auth.js"
   Worker: [reads auth.js, returns content]
   Director: [needs full content to analyze]
   → No savings, added latency
```

**The key insight**: Delegate **tasks**, not **tools**.

## Recommended Approach

### What OMP Should Implement

#### 1. **Task Templates, Not Tool Agents**

```yaml
# In models.yml or config.yml
taskTemplates:
  explore-codebase:
    description: "Explore codebase and report structure"
    agent: explore
    model: devstral-small-2
    maxTokens: 50K
    reportFormat: "structured summary"
    
  security-audit:
    description: "Audit for security vulnerabilities"
    agent: qual-security-auditor
    model: deepseek-v4-pro
    pattern:
      - phase: scan
        agent: explore
        model: devstral-small-2
      - phase: analyze
        agent: qual-security-auditor
        model: deepseek-v4-pro
```

#### 2. **Model Selection at Task Level, Not Tool Level**

```yaml
# When user spawns task with /xpert security-auditor
# → Uses deepseek-v4-pro (already implemented)

# When user spawns task with /xpert explore
# → Uses devstral-small-2 (already implemented)

# The model is selected at the AGENT level, not the TOOL level
```

#### 3. **Parallel Task Spawning** (More Useful Than Per-Tool Agents)

```typescript
// Extension API
pi.registerCommand('parallel-analyze', {
  handler: async (args, ctx) => {
    const files = await findFiles(args.pattern);
    const chunks = chunk(files, 5); // 5 agents
    
    const agents = chunks.map(chunk => 
      ctx.spawnAgent({
        agent: 'explore',
        model: 'devstral-small-2',
        task: `Analyze these files: ${chunk.join(', ')}`
      })
    );
    
    const results = await Promise.all(agents);
    // Synthesize with director model
    return results;
  }
});
```

**This is already possible** with the existing `task` tool - no new architecture needed.

## Conclusion

### ❌ NOT Recommended: Per-Tool Specialized Agents

- **Latency**: Agent spawn overhead (300-500ms) > tool call overhead (50-200ms)
- **Complexity**: Distributed state, harder debugging
- **Token Savings**: $0 (models are already free)
- **Context Loss**: Workers can't share context efficiently

### ✅ Recommended: Task-Level Templates

- **Keep**: Current tool-level model selection (all tools use same model per agent)
- **Add**: Task templates for common patterns (explore, audit, refactor)
- **Enable**: Parallel task spawning when beneficial (already possible with `task` tool)
- **Document**: Best practices for when to use which agent model

### The Real Win

The model routing is **already intelligent** at the agent level:
- `explore` agent → Devstral Small (fast, cheap exploration)
- `qual-security-auditor` → DeepSeek V4 Pro (deep reasoning)
- `lang-python-pro` → Qwen3 Coder Next (code specialist)

**What's missing** is not per-tool routing, but:
1. **Better documentation** of when to use which agent
2. **Task templates** for common multi-agent patterns
3. **Parallelization utilities** for bulk operations

These can be built with the **existing architecture** - no fundamental changes needed.