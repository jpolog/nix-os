# Agent Model Display Extension - Implementation Summary

## What Was Created

A new OMP extension that **displays which model each agent uses** when spawned.

### Files Created

1. **`extensions/agent-model-display/index.ts`** (12KB)
   - Main extension logic
   - Tracks agent spawns and displays model info
   - Loads model mappings from config files

2. **`extensions/agent-model-display/README.md`** (4.5KB)
   - Documentation
   - Usage examples
   - Technical details

3. **`config.yml`** (updated)
   - Added extension to load list

## How It Works

### On Agent Spawn

```
User: "Explore the codebase"
    ↓
GLM-5 spawns explore agent
    ↓
Extension intercepts 'agent_start' event
    ↓
Extension displays: 💨 Spawned explore [devstral-small-2]
```

### Model Detection Flow

```
1. Check agent frontmatter (agents/*.md)
   model: ollama/qwen3-coder-next:cloud
   
2. If not found, check role-map.yml
   lang-python-pro = code-specialist
   
3. Resolve role in models.yml
   code-specialist = "ollama/qwen3-coder-next:cloud"
   
4. If built-in agent, use config.yml modelRoles
   explore → smol → devstral-small-2
   
5. If unknown, use heuristics
   agent.includes("security") → deepseek-v4-pro (assumed)
```

## Commands Added

### `/agent-models [agent-name]`

Shows all agents grouped by model tier:

```
## 🔥 Frontier (Deep Reasoning)

- **qual-security-auditor** (deep-audit): deepseek-v4-pro
- **dev-api-designer** (architecture-planning): kimi-k2.6

## ⚡ Balanced (Coding)

- **lang-python-pro** (code-specialist): qwen3-coder-next
- **lang-typescript-pro** (code-specialist): qwen3-coder-next

## 💨 Fast (Quick Tasks)

- **explore** (built-in): devstral-small-2
- **quick_task** (built-in): devstral-small-2
```

### `/agent-activity`

Shows recent agent spawns with models:

```
[14:32:15] ▶️ 💨 explore [devstral-small-2]
[14:32:32] ⏹️ 💨 explore [devstral-small-2] - completed
[14:33:00] ▶️ 🔥 lang-python-pro [qwen3-coder-next]
[14:33:45] ⏹️ 🔥 lang-python-pro [qwen3-coder-next] - completed

**Summary:** 2 started, 2 completed
```

## Model Tier Emojis

| Tier | Emoji | Models | Use Case |
|------|-------|--------|----------|
| Frontier | 🔥 | deepseek-v4-pro, kimi-k2.6, qwen3.5, glm-5.1 | Deep reasoning, audits |
| Balanced | ⚡ | qwen3-coder-next, glm-5.1, devstral-2 | Coding, engineering |
| Fast | 💨 | devstral-small-2 | Quick tasks, exploration |
| Multimodal | 👁️ | gemini, vl | Visual analysis |

## Real-Time Notifications

When an agent is spawned, the extension displays:

```
💨 Spawned explore [devstral-small-2]
```

This shows:
- Emoji indicating model tier
- Agent name
- Model being used

## Use Cases

### 1. See What Model is Used

```
/agent-models python
```

Output:
```
- **lang-python-pro** (code-specialist): qwen3-coder-next
- **lang-django-developer** (code-specialist): qwen3-coder-next
- **lang-fastapi-developer** (code-specialist): qwen3-coder-next
```

### 2. Check Cost Awareness

When you see:
```
🔥 Spawned qual-security-auditor [deepseek-v4-pro]
```

You know: "This is using the expensive frontier model for deep security analysis."

### 3. Verify Cheap Agents

When you see:
```
💨 Spawned explore [devstral-small-2]
```

You know: "GLM-5 correctly delegated to the cheap/fast exploration agent."

## Technical Details

### Events Tracked

```typescript
pi.on('agent_start', (event) => {
  const agentName = event.agent;
  const model = getModelForAgent(agentName);
  // Display: "💨 Spawned explore [devstral-small-2]"
});

pi.on('agent_end', (event) => {
  const agentName = event.agent;
  // Track completion
});
```

### Files Read

1. **`agents/*.md`** - Parse YAML frontmatter for model assignment
2. **`role-map.yml`** - Resolve agent → role → model
3. **`models.yml`** - Model definitions and tiers
4. **`config.yml`** - Model role assignments (smol, default, slow, plan)

### No External Dependencies

Uses only what's already in OMP:
- `fs` - File system
- `path` - Path utilities
- `yaml` - YAML parsing (already used by xpert extension)
- `ExtensionAPI` - OMP extension interface

## Benefits

1. **Transparency**: You see exactly which model each agent uses
2. **Cost Awareness**: Know when expensive models are used
3. **Optimization**: Verify cheap agents are used for cheap tasks
4. **Debugging**: Track agent lifecycle and model assignments
5. **Education**: Learn which agents use which models

## Testing

### Restart OMP

```bash
# The extension will load on next OMP start
omp
```

### Try Commands

```
/agent-models
/agent-activity
```

### Spawn Agents

```
# Use a Python agent
/xpert lang-python-pro

# You should see:
⚡ Spawned lang-python-pro [qwen3-coder-next]

# Use security auditor
/xpert qual-security-auditor

# You should see:
🔥 Spawned qual-security-auditor [deepseek-v4-pro]
```

## Future Enhancements

Possible improvements:
- Token cost estimation (input × cost_per_token)
- Budget alerts when expensive agents spawn
- Usage statistics (how often each model is used)
- Cost optimization recommendations
- Historical analysis of agent → model usage

## Summary

This extension makes OMP's intelligent delegation **transparent**. You can now see:

- When GLM-5 delegates to cheap agents (💨)
- When expensive agents are used (🔥)
- Which agents use which models
- Recent activity with models

**The key insight**: GLM-5 automatically delegates to the right agents, and this extension shows you that it's happening correctly.