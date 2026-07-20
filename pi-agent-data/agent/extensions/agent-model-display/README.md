# Agent Model Display Extension

Shows which model each agent uses when spawned, making delegation transparent.

## Features

- **Automatic Model Display**: Shows model when an agent is spawned
- **Model Tiers**: Groups agents by tier (Frontier, Balanced, Fast, Multimodal)
- **Activity Tracking**: Logs agent spawns with model information
- **Model Switch Tracking**: Shows when models are switched

## Commands

### `/agent-models [agent-name]`

Show model assignments for all agents or search by name.

```
/agent-models              # Show all agents
/agent-models python      # Show agents matching "python"
/agent-models security    # Show security-related agents
```

Output:
```
# Agent Model Assignments

## 🔥 Frontier (Deep Reasoning)

- **qual-security-auditor** (deep-audit): deepseek-v4-pro
- **dev-api-designer** (architecture-planning): kimi-k2.6
- **res-phd-peer-reviewer** (deep-audit): deepseek-v4-pro

## ⚡ Balanced (Coding)

- **lang-python-pro** (code-specialist): qwen3-coder-next
- **lang-typescript-pro** (code-specialist): qwen3-coder-next
- **dev-backend-developer** (code-specialist): qwen3-coder-next

## 💨 Fast (Quick Tasks)

- **explore** (built-in): devstral-small-2
- **quick_task** (built-in): devstral-small-2
- **dx-readme-generator** (fast-coding): devstral-small-2

## 🤖 Other Models

- **meta-multi-agent-coordinator** (multi-agent): nemotron-3-super
```

### `/agent-activity`

Show recent agent activity with model information.

```
/agent-activity
```

Output:
```
# Agent Activity Log

[14:32:15] ▶️ 💨 explore [devstral-small-2]
[14:32:32] ⏹️ 💨 explore [devstral-small-2] - completed
[14:32:33] ▶️ 💨 explore [devstral-small-2]
[14:32:50] ⏹️ 💨 explore [devstral-small-2] - completed
[14:33:00] ▶️ 🔥 lang-python-pro [qwen3-coder-next]
[14:33:45] ⏹️ 🔥 lang-python-pro [qwen3-coder-next] - completed

**Summary:** 3 started, 3 completed
```

## How It Works

### Model Detection

1. **Custom Agents**: Reads model from `agents/*.md` frontmatter
2. **Role Mapping**: Resolves via `role-map.yml` → `models.yml`
3. **Built-in Agents**: Uses `config.yml` model roles (smol, default, slow, plan)
4. **Fallback**: Heuristics based on agent name patterns

### Model Tiers

The extension categorizes models into tiers:

| Tier | Models | Emoji | Use Case |
|------|--------|-------|----------|
| Frontier | deepseek-v4-pro, kimi-k2.6 | 🔥 | Deep reasoning, security audits |
| Balanced | qwen3-coder-next, glm-5.1 | ⚡ | Coding, engineering |
| Fast | devstral-small-2 | 💨 | Quick tasks, exploration |
| Multimodal | gemini, vl | 👁️ | Visual analysis |

### Activity Tracking

Tracks events:
- `agent_start`: Agent spawned with model
- `agent_end`: Agent completed
- `model_change`: Model switched

## Configuration

The extension automatically loads model assignments from:
- `~/.omp/agent/agents/*.md` - Agent definitions
- `~/.omp/agent/role-map.yml` - Role mappings
- `~/.omp/agent/models.yml` - Model definitions
- `~/.omp/agent/config.yml` - Model roles

## Examples

### When an Agent is Spawned

```
💨 Spawned explore [devstral-small-2]
```

Shows that `explore` agent is using the cheap/fast model.

```
🔥 Spawned qual-security-auditor [deepseek-v4-pro]
```

Shows that security auditor is using the expensive/deep reasoning model.

### Check Your Setup

```
/agent-models | grep python
```

Shows all Python-related agents and their models:

```
- **lang-python-pro** (code-specialist): qwen3-coder-next
- **lang-django-developer** (code-specialist): qwen3-coder-next
- **lang-fastapi-developer** (code-specialist): qwen3-coder-next
```

### See Recent Activity

```
/agent-activity
```

Shows which agents were spawned and with what models.

## Benefits

1. **Transparency**: See exactly which model each agent uses
2. **Cost Awareness**: Know when expensive models are used
3. **Optimization**: Identify if cheap agents are being used appropriately
4. **Debugging**: Track agent lifecycle and model switches

## Technical Details

### Events Used

- `agent_start` - Track agent spawns
- `agent_end` - Track agent completions
- `model_change` - Track model switches

### Files Read

- `agents/*.md` - Parse YAML frontmatter
- `role-map.yml` - Resolve role → model mapping
- `models.yml` - Model definitions and tiers
- `config.yml` - Model role assignments

### No External Dependencies

Uses only:
- `fs` - File system access
- `path` - Path utilities
- `yaml` - YAML parsing (already in OMP)
- `ExtensionAPI` - OMP extension interface