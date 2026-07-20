/**
 * Model Switcher Extension - ACTUAL WORKING VERSION
 * 
 * Quickly switch between models.
 * Uses REAL APIs: ctx.model, ctx.ui.select()
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function modelSwitcherExtension(pi: ExtensionAPI) {
  pi.registerCommand('model', {
    description: 'Switch active model',
    handler: async (args, ctx) => {
      const subcommand = args.trim().toLowerCase();
      
      if (subcommand === 'list' || subcommand === 'models') {
        // Show common models organized by tier
        const models = [
          { tier: 'Tier 1 - Frontier (Deep Reasoning)', models: [
            'ollama/deepseek-v4-pro',
            'ollama/kimi-k2.6:cloud',
            'ollama/qwen3.5:cloud',
            'ollama/glm-5.1'
          ]},
          { tier: 'Tier 2 - Balanced (Day-to-Day)', models: [
            'ollama/deepseek-v4-flash',
            'ollama/qwen3-coder-next:cloud',
            'ollama/devstral-2:123b'
          ]},
          { tier: 'Tier 3 - Fast (Exploration)', models: [
            'ollama/devstral-small-2:24b-cloud',
            'ollama/nemotron-3-super'
          ]},
          { tier: 'Tier 4 - Multimodal (Vision)', models: [
            'ollama/gemini-3-flash-preview',
            'ollama/qwen3-vl:235b'
          ]}
        ];
        
        const output = models.map(tier => 
          `${tier.tier}:\n${tier.models.map(m => `  ${m}`).join('\n')}`
        ).join('\n\n');
        
        await ctx.ui.editor('Available Models', output + '\n\nUsage: /model <model-id>');
        return;
      }
      
      if (!subcommand) {
        // Show current model
        const currentModel = ctx.model;
        if (currentModel) {
          ctx.ui.notify(`Current model: ${currentModel.id}`, 'info');
        } else {
          ctx.ui.notify('No model currently active', 'warning');
        }
        
        const usage = ctx.getContextUsage();
        if (usage && usage.tokens !== null) {
          ctx.ui.notify(
            `Context usage: ${usage.tokens.toLocaleString()} / ${usage.contextWindow.toLocaleString()} tokens (${usage.percent?.toFixed(1)}%)`,
            'info'
          );
        }
        return;
      }
      
      // Switch model using the REAL API
      const modelId = args.trim();
      const success = await pi.setModel({ id: modelId });
      
      if (success) {
        ctx.ui.notify(`✓ Switched to ${modelId}`, 'info');
      } else {
        ctx.ui.notify(`✗ Failed to switch to ${modelId}\n\nMake sure the model ID is correct and you have API access.`, 'error');
      }
    }
  });
}

export const metadata = {
  name: 'model-switcher',
  version: '1.0.0',
  description: 'Quick model switching using real ExtensionAPI',
  author: 'OMP Team'
};