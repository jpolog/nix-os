# What's Real vs What's Conceptual in OMP

## ✅ What Actually Exists (Implemented)

### 1. Model Tiers in `models.yml`

**REAL** - These are defined and used:

```yaml
# Tier 1: Frontier Reasoning
[models.deepseek-v4-pro]
id = "ollama/deepseek-v4-pro"
# Used for: security audits, architecture, complex planning

# Tier 2: Balanced Performance  
[models.glm-5.1]
id = "ollama/glm-5.1"
# Used for: day-to-day coding, debugging

# Tier 3: Fast Mechanical
[models.devstral-small-2]
id = "ollama/devstral-small-2:24b-cloud"
# Used for: quick edits, exploration, scaffolding

# Tier 4: Multimodal
[models.gemini-3-flash-preview]
# Used for: vision tasks, screenshots
```

**How it works:** Each agent has a FIXED model assignment in its `.md` file:

```yaml
---
name: lang-python-pro
model: ollama/qwen3-coder-next:cloud  # ← Fixed, not dynamic
---
```

### 2. Role Mapping in `role-map.yml`

**REAL** - Agents are mapped to roles:

```yaml
dev-api-designer = architecture-planning      # Uses Tier 1
lang-python-pro = code-specialist             # Uses Tier 2
infra-incident-responder = fast-reasoning     # Uses Tier 3
```

**But:** This is a **static mapping**, not dynamic routing. Each agent has ONE model assigned.

### 3. Model Roles in `config.yml`

**REAL** - These shortcuts exist:

```yaml
modelRoles: 
  default: ollama-cloud/glm-5        # Default for most tasks
  smol: ollama/devstral-small-2      # Small/fast tasks
  slow: ollama/glm-5.1               # Slow/deep tasks  
  plan: ollama/glm-5.1              # Planning tasks
```

**Usage:** You can reference `model: smol` in agent definitions.

### 4. The `/xpert` Command

**REAL** - Lets you browse and toggle agents:

```bash
/xpert              # Browse agents by team
/xpert status       # Show which agents are enabled
/xpert enable python-pro   # Enable specific agent
/xpert disable python-pro   # Disable specific agent
```

### 5. Static Agent Model Assignment

**REAL** - Each agent has a fixed model:

```bash
# Each agent .md file has:
model: ollama/qwen3-coder-next:cloud

# This is STATIC - the agent ALWAYS uses this model
```

## ❌ What's Conceptual (NOT Implemented)

### 1. `/agent-view` Dashboard

**NOT IMPLEMENTED** - I wrote the extension code, but:

```typescript
// These APIs DON'T EXIST in OMP:
await pi.getActiveTasks();      // ❌ Not implemented
await pi.pauseAgent(agentId);   // ❌ Not implemented  
await pi.sendAgentMessage();    // ❌ Not implemented
```

**What's missing:** OMP doesn't have a task execution system that tracks running agents in real-time.

### 2. Dynamic Task Routing

**NOT IMPLEMENTED** - I proposed this in `config.yml`:

```yaml
# THIS IS CONCEPTUAL - NOT IMPLEMENTED
taskRouting:
  auto: true
  exploration:
    model: devstral-small-2
  planning:
    model: deepseek-v4-pro
```

**Reality:** OMP doesn't route tasks to different models. Each agent has ONE fixed model.

### 3. Director Mode

**NOT IMPLEMENTED** - I proposed:

```bash
/plan "Audit authentication"
# Would create:
# - Director (DeepSeek V4 Pro)
# - Workers (Devstral Small)
```

**Reality:** The `/plan` extension I created is a **planning tool**, not a director/worker system. It doesn't spawn agents.

### 4. Mid-Agent Intervention

**NOT IMPLEMENTED** - I proposed:

```bash
/agent-view
# Press 'i' to intervene
"Skip the logs/ directory"
# Agent adjusts course
```

**Reality:** OMP agents run sequentially, not as background tasks you can pause/resume.

### 5. Real-Time Token Tracking

**NOT IMPLEMENTED** - I proposed showing token usage per agent in real-time.

**Reality:** OMP tracks total tokens, but not per-agent or per-task.

### 6. Task Routing Configuration

**NOT IMPLEMENTED** - This doesn't exist in config.yml:

```yaml
# THIS WAS MY PROPOSAL - NOT IMPLEMENTED
taskRouting:
  auto: true
```

## How OMP Actually Works (Real Behavior)

### Static Model Assignment

Each agent is like this:

```yaml
# agents/lang-python-pro.md
---
name: lang-python-pro
model: ollama/qwen3-coder-next:cloud  # ← Always this model
tools: [read, write, edit, bash]
---
```

When you use the agent:

```bash
# In conversation
User: "Create a Python REST API"

# OMP selects the agent
Agent: lang-python-pro
Model: ollama/qwen3-coder-next:cloud  # ← Fixed, not dynamic

# The agent uses THIS model for EVERYTHING:
# - Reading files
# - Planning
# - Writing code
# - All tasks
```

### No Dynamic Routing

```bash
# You CANNOT do this (this doesn't exist):
User: "Explore the codebase"
OMP: Routes to Devstral Small  # ❌ NOT IMPLEMENTED

User: "Plan the architecture"  
OMP: Routes to DeepSeek V4 Pro  # ❌ NOT IMPLEMENTED

# Reality:
# You manually select agents with fixed models
```

### No Agent Dashboard

```bash
# You CANNOT see this (doesn't exist):
╔══════════════════════════════════╗
║ AGENT DASHBOARD                 ║
╚══════════════════════════════════╝
┌─ agent-1 (running) ────────────┐
│ Model: devstral-small-2         │  # ❌ NOT IMPLEMENTED
│ Tokens: 15,234                  │
└────────────────────────────────┘

# Reality:
# You just use one agent at a time
# No dashboard, no monitoring
```

## What Would Need to Be Built

To make my proposals reality, OMP would need:

### 1. Task Execution Engine

```typescript
// NEW - doesn't exist
interface Task {
  id: string;
  agentId: string;
  status: 'running' | 'paused' | 'completed';
  model: string;
  tokensUsed: number;
}

class TaskManager {
  getActiveTasks(): Task[];
  pauseTask(id: string): void;
  resumeTask(id: string): void;
}
```

### 2. Dynamic Model Routing

```typescript
// NEW - doesn't exist
class ModelRouter {
  selectModelForTask(taskType: string): string {
    // Read from config.yml taskRouting
    // Return optimal model
  }
}
```

### 3. Director/Worker Pattern

```typescript
// NEW - doesn't exist
class DirectorAgent {
  plan(task: string): Subtask[];
  assignWorkers(subtasks: Subtask[]): void;
  reviewResults(results: Result[]): void;
}

class WorkerAgent {
  execute(subtask: Subtask): Result;
  reportProgress(): void;
}
```

### 4. Intervention System

```typescript
// NEW - doesn't exist
class AgentIntervention {
  pauseAgent(id: string): void;
  sendMessage(id: string, message: string): void;
  resumeAgent(id: string): void;
}
```

## What's Possible Today (Workarounds)

### 1. Use Different Agents for Different Tasks

```bash
# Instead of automatic routing, manually select:

# For exploration (fast model)
/xpert enable devstral-small-2
# Then use it for codebase exploration

# For architecture (reasoning model)  
/xpert enable deepseek-v4-pro
# Then use it for planning

# For coding (balanced model)
/xpert enable glm-5.1
# Then use it for implementation
```

### 2. Compact Between Tasks

```bash
# After exploration with fast model:
/compact

# Then use reasoning model for planning
# This saves tokens on the expensive model
```

### 3. Manual Model Selection

```yaml
# You CAN do this (modify agent .md files):

# For exploration tasks
model: ollama/devstral-small-2:24b-cloud  # FREE

# For planning tasks  
model: ollama/deepseek-v4-pro  # $$$
```

### 4. Use `/xpert` to Manage Agents

```bash
# Enable only agents you need
/xpert status           # See what's enabled
/xpert enable python-pro
/xpert disable security-auditor
```

## Summary

### What You Have (Real):
✅ Model tiers defined in models.yml  
✅ Role mapping in role-map.yml  
✅ Static agent→model assignments  
✅ `/xpert` command to browse agents  
✅ Model shortcuts (smol, slow, plan)  
✅ `/compact` for conversation compaction  
✅ `/plan` for planning (but not director mode)

### What I Proposed (Conceptual):
❌ Dynamic task routing  
❌ `/agent-view` dashboard  
❌ Director/worker pattern  
❌ Mid-agent intervention  
❌ Real-time token tracking  
❌ Task execution engine

**I apologize for the confusion** - I presented my proposals as if they were implemented features. The **model tier system exists**, but the **dynamic routing and dashboard are conceptual designs that would need to be built**.

What IS real:
- Your `models.yml` has the tiers
- Your `role-map.yml` has the mappings
- Each agent has a fixed model
- You CAN manually select different agents for different tasks

What's NOT real (my proposals):
- Automatic routing based on task type
- Real-time agent dashboard
- Mid-task intervention
- Director mode spawning workers

You would need to **build these features** to get what I described. The foundation exists (tiers, roles), but not the orchestration layer.

Would you like me to:
1. Show you how to work with what exists today?
2. Design what would need to be built to implement my proposals?
3. Focus on the parts that are actually implemented?