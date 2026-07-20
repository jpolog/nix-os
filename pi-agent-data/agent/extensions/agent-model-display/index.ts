/**
 * Agent Model Display Extension
 *
 * Shows which model each agent uses when spawned.
 * Loads model mappings from agents/*.md frontmatter and role-map.yml
 *
 * Usage: Automatically tracks agent spawns via events
 * Command: /agent-models - Show model assignments for all agents
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import * as fs from "fs";
import * as path from "path";
import * as yaml from "js-yaml";

interface AgentModelInfo {
  name: string;
  model: string;
  role?: string;
  description?: string;
}

interface ActivityEvent {
  type: "agent_start" | "agent_end" | "model_switch";
  timestamp: number;
  agent?: string;
  model?: string;
  details?: string;
}

export default function agentModelDisplayExtension(pi: ExtensionAPI) {
  const agentsDir = path.join(os.homedir(), ".omp", "agent", "agents");
  const roleMapPath = path.join(os.homedir(), ".omp", "agent", "role-map.yml");
  const modelsPath = path.join(os.homedir(), ".omp", "agent", "models.yml");

  const agentModels: Map<string, AgentModelInfo> = new Map();
  const activityLog: ActivityEvent[] = [];
  const MAX_LOG_SIZE = 100;

  // Load agent model mappings
  function loadAgentModels(): void {
    try {
      // Load role mappings
      const roleMapContent = fs.readFileSync(roleMapPath, "utf-8");
      const roleMap = yaml.load(roleMapContent) as Record<string, string>;

      // Load models
      const modelsContent = fs.readFileSync(modelsPath, "utf-8");
      const models = yaml.load(modelsContent) as Record<string, unknown>;

      // Load agent frontmatter
      const agentFiles = fs.readdirSync(agentsDir).filter((f) => f.endsWith(".md"));

      for (const file of agentFiles) {
        const filePath = path.join(agentsDir, file);
        const content = fs.readFileSync(filePath, "utf-8");

        // Parse frontmatter
        const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
        if (!frontmatterMatch) continue;

        const frontmatter = yaml.load(frontmatterMatch[1]) as Record<string, unknown>;
        const agentName = (frontmatter.name as string) || file.replace(".md", "");
        const model = frontmatter.model as string;

        // Get role from role-map if model not in frontmatter
        let resolvedModel = model;
        if (!resolvedModel && roleMap[agentName]) {
          const role = roleMap[agentName];
          // Role points to model ID in models section
          resolvedModel = (models.roles as Record<string, string>)?.[role];
        }

        if (agentName && resolvedModel) {
          agentModels.set(agentName, {
            name: agentName,
            model: resolvedModel,
            role: roleMap[agentName],
            description: frontmatter.description as string,
          });
        }
      }

      // Add built-in agents with their model roles
      const modelRoles = (models as Record<string, unknown>).modelRoles as Record<string, string>;
      if (modelRoles) {
        agentModels.set("explore", {
          name: "explore",
          model: modelRoles.smol || "devstral-small-2",
          description: "Fast read-only codebase scout",
        });
        agentModels.set("task", {
          name: "task",
          model: modelRoles.default || "glm-5",
          description: "General-purpose subagent",
        });
        agentModels.set("plan", {
          name: "plan",
          model: modelRoles.plan || "glm-5.1",
          description: "Multi-file architectural planning",
        });
        agentModels.set("oracle", {
          name: "oracle",
          model: modelRoles.slow || "glm-5.1",
          description: "Senior engineer for complex decisions",
        });
        agentModels.set("designer", {
          name: "designer",
          model: modelRoles.default || "glm-5",
          description: "UI/UX specialist",
        });
        agentModels.set("reviewer", {
          name: "reviewer",
          model: modelRoles.slow || "glm-5.1",
          description: "Code review specialist",
        });
        agentModels.set("librarian", {
          name: "librarian",
          model: modelRoles.default || "glm-5",
          description: "External library researcher",
        });
        agentModels.set("quick_task", {
          name: "quick_task",
          model: modelRoles.smol || "devstral-small-2",
          description: "Low-reasoning mechanical updates",
        });
      }

      pi.sendMessage({
        customType: "agent-models-loaded",
        content: `Loaded ${agentModels.size} agent model mappings`,
        display: false,
      });
    } catch (err) {
      pi.sendMessage({
        customType: "agent-models-error",
        content: `Error loading agent models: ${(err as Error).message}`,
        display: true,
      });
    }
  }

  // Get model for an agent
  function getModelForAgent(agentName: string): string {
    const info = agentModels.get(agentName);
    if (info) {
      return info.model;
    }

    // Try to extract model from agent name patterns
    if (agentName.includes("security") || agentName.includes("audit")) {
      return "deepseek-v4-pro (assumed)";
    }
    if (agentName.includes("python") || agentName.includes("typescript")) {
      return "qwen3-coder-next (assumed)";
    }
    if (agentName.includes("explore") || agentName.includes("quick")) {
      return "devstral-small-2 (assumed)";
    }

    return "unknown model";
  }

  // Format model name for display
  function formatModelName(model: string): string {
    // Extract just the model name from full ID
    // "ollama/qwen3-coder-next:cloud" -> "qwen3-coder-next"
    const match = model.match(/\/([^:]+)/);
    return match ? match[1] : model;
  }

  // Get model tier emoji
  function getModelEmoji(model: string): string {
    if (model.includes("deepseek-v4-pro") || model.includes("kimi")) {
      return "🔥"; // Frontier
    }
    if (model.includes("qwen3-coder") || model.includes("glm-5")) {
      return "⚡"; // Balanced
    }
    if (model.includes("devstral-small") || model.includes("smol")) {
      return "💨"; // Fast
    }
    if (model.includes("gemini") || model.includes("vl")) {
      return "👁️"; // Multimodal
    }
    return "🤖"; // Default
  }

  // Add activity event
  function addActivity(event: Omit<ActivityEvent, "timestamp">): void {
    activityLog.push({
      ...event,
      timestamp: Date.now(),
    });

    if (activityLog.length > MAX_LOG_SIZE) {
      activityLog.shift();
    }
  }

  // Track agent lifecycle with model display
  pi.on("agent_start", (event) => {
    const agentName = event.agent || "unknown";
    const model = getModelForAgent(agentName);
    const formattedModel = formatModelName(model);
    const emoji = getModelEmoji(model);

    addActivity({
      type: "agent_start",
      agent: agentName,
      model: formattedModel,
      details: `${emoji} ${agentName} [${formattedModel}]`,
    });

    // Send notification for agent spawn
    pi.sendMessage({
      customType: "agent-spawn",
      content: `${emoji} Spawned ${agentName} [${formattedModel}]`,
      display: true,
    });
  });

  pi.on("agent_end", (event) => {
    const agentName = event.agent || "unknown";
    const model = getModelForAgent(agentName);
    const formattedModel = formatModelName(model);
    const emoji = getModelEmoji(model);

    addActivity({
      type: "agent_end",
      agent: agentName,
      model: formattedModel,
      details: `${emoji} ${agentName} [${formattedModel}] - ${event.status}`,
    });
  });

  // Track model switches
  pi.on("model_change", (event) => {
    addActivity({
      type: "model_switch",
      model: event.model,
      details: `Switched to ${event.model}`,
    });
  });

  // Command: Show all agent model assignments
  pi.registerCommand("agent-models", {
    description: "Show model assignments for all agents",
    usage: "/agent-models [agent-name]",

    handler: async (args: string) => {
      // Load models if not loaded
      if (agentModels.size === 0) {
        loadAgentModels();
      }

      const searchTerm = args.trim().toLowerCase();

      // Filter by search term if provided
      const agents = searchTerm
        ? Array.from(agentModels.values()).filter((a) =>
            a.name.toLowerCase().includes(searchTerm)
          )
        : Array.from(agentModels.values());

      if (agents.length === 0) {
        pi.sendMessage({
          customType: "agent-models-empty",
          content: "No agents found matching that name",
          display: true,
        });
        return;
      }

      // Build output
      let output = "# Agent Model Assignments\n\n";
      output += `**Total agents:** ${agents.length}\n\n`;

      // Group by model
      const byModel: Map<string, AgentModelInfo[]> = new Map();
      for (const agent of agents) {
        const model = agent.model;
        if (!byModel.has(model)) {
          byModel.set(model, []);
        }
        byModel.get(model)!.push(agent);
      }

      // Display by tier
      const tiers = [
        { name: "🔥 Frontier (Deep Reasoning)", models: ["deepseek-v4-pro", "kimi-k2.6", "qwen3.5:cloud", "glm-5.1:cloud"] },
        { name: "⚡ Balanced (Coding)", models: ["qwen3-coder-next", "glm-5.1", "devstral-2"] },
        { name: "💨 Fast (Quick Tasks)", models: ["devstral-small-2", "smol"] },
        { name: "👁️ Multimodal (Vision)", models: ["gemini", "vl"] },
      ];

      for (const tier of tiers) {
        const tierAgents: AgentModelInfo[] = [];
        for (const [model, agents] of byModel) {
          const isTierModel = tier.models.some((m) => model.includes(m));
          if (isTierModel) {
            tierAgents.push(...agents);
            byModel.delete(model);
          }
        }

        if (tierAgents.length > 0) {
          output += `## ${tier.name}\n\n`;
          for (const agent of tierAgents.sort((a, b) => a.name.localeCompare(b.name))) {
            const roleInfo = agent.role ? ` (${agent.role})` : "";
            const desc = agent.description ? ` - ${agent.description.substring(0, 60)}...` : "";
            output += `- **${agent.name}**${roleInfo}: ${formatModelName(agent.model)}${desc}\n`;
          }
          output += "\n";
        }
      }

      // Remaining (other models)
      if (byModel.size > 0) {
        output += "## 🤖 Other Models\n\n";
        for (const [model, agents] of byModel) {
          output += `### ${formatModelName(model)}\n\n`;
          for (const agent of agents.sort((a, b) => a.name.localeCompare(b.name))) {
            const roleInfo = agent.role ? ` (${agent.role})` : "";
            output += `- **${agent.name}**${roleInfo}\n`;
          }
          output += "\n";
        }
      }

      // Recent activity
      if (activityLog.length > 0) {
        output += "---\n\n## Recent Activity\n\n";
        output += "```\n";
        for (const event of activityLog.slice(-10).reverse()) {
          const time = new Date(event.timestamp).toLocaleTimeString();
          output += `[${time}] ${event.details}\n`;
        }
        output += "```\n";
      }

      pi.sendMessage({
        customType: "agent-models",
        content: output,
        display: true,
      });
    },
  });

  // Command: Show activity log with models
  pi.registerCommand("agent-activity", {
    description: "Show recent agent activity with model information",
    usage: "/agent-activity",

    handler: async () => {
      if (activityLog.length === 0) {
        pi.sendMessage({
          customType: "agent-activity-empty",
          content: "No agent activity recorded yet",
          display: true,
        });
        return;
      }

      let output = "# Agent Activity Log\n\n";
      output += "```\n";

      for (const event of activityLog.slice(-20).reverse()) {
        const time = new Date(event.timestamp).toLocaleTimeString();
        const emoji = event.type === "agent_start" ? "▶️" : event.type === "agent_end" ? "⏹️" : "🔄";
        output += `${time} ${emoji} ${event.details}\n`;
      }

      output += "```\n";

      // Activity summary
      const starts = activityLog.filter((e) => e.type === "agent_start").length;
      const ends = activityLog.filter((e) => e.type === "agent_end").length;
      output += `\n**Summary:** ${starts} started, ${ends} completed\n`;

      pi.sendMessage({
        customType: "agent-activity",
        content: output,
        display: true,
      });
    },
  });

  // Load on startup
  loadAgentModels();
}

export const metadata = {
  name: "agent-model-display",
  version: "1.0.0",
  description: "Display model assignments for agents during task execution",
  author: "OMP Team",
};