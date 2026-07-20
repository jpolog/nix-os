/**
 * Token Tracker Extension - ACTUAL WORKING VERSION
 * 
 * Tracks token usage from the session context.
 * Uses REAL APIs: ctx.getContextUsage(), pi.on('message_end')
 * 
 * Usage: /tokens [reset]
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

interface TokenStats {
  total: number;
  byAgent: Map<string, number>;
  history: Array<{ time: number; tokens: number; agent?: string }>;
}

export default function tokenTrackerExtension(pi: ExtensionAPI) {
  const stats: TokenStats = {
    total: 0,
    byAgent: new Map(),
    history: []
  };
  
  // Track tokens from message events
  pi.on('message_end', (event) => {
    const tokens = event.tokens || 0;
    stats.total += tokens;
    stats.history.push({
      time: Date.now(),
      tokens,
      agent: event.agent
    });
    
    if (event.agent) {
      const current = stats.byAgent.get(event.agent) || 0;
      stats.byAgent.set(event.agent, current + tokens);
    }
  });
  
  pi.registerCommand('tokens', {
    description: 'Show token usage statistics',
    handler: async (args, ctx) => {
      const subcommand = args.trim().toLowerCase();
      
      if (subcommand === 'reset') {
        stats.total = 0;
        stats.byAgent.clear();
        stats.history = [];
        
        ctx.ui.notify('Token counter reset', 'info');
        return;
      }
      
      if (subcommand === 'history') {
        const recentHistory = stats.history.slice(-20);
        const output = recentHistory.map(h => 
          `[${new Date(h.time).toISOString()}] ${h.tokens} tokens${h.agent ? ` (${h.agent})` : ''}`
        ).join('\n');
        
        await ctx.ui.editor('Token History', output);
        return;
      }
      
      if (subcommand === 'usage') {
        // Use the REAL API
        const usage = ctx.getContextUsage();
        
        if (!usage || usage.tokens === null) {
          ctx.ui.notify('Token usage unknown (e.g., right after compaction)', 'warning');
          return;
        }
        
        const percent = usage.percent !== null ? usage.percent.toFixed(1) : 'unknown';
        
        ctx.ui.notify(
          `Context Usage: ${usage.tokens.toLocaleString()} / ${usage.contextWindow.toLocaleString()} tokens (${percent}%)`,
          'info'
        );
        return;
      }
      
      // Default: show summary
      const agentBreakdown = Array.from(stats.byAgent.entries())
        .map(([agent, tokens]) => `  ${agent}: ${tokens.toLocaleString()}`)
        .join('\n');
      
      const message = `📊 Token Statistics

Total tracked: ${stats.total.toLocaleString()}

By agent:
${agentBreakdown || '  (no data yet)'}

Commands:
  /tokens         - Show this summary
  /tokens usage   - Show current context usage
  /tokens reset   - Reset counter
  /tokens history - Show recent usage`;
      
      ctx.ui.notify(message, 'info');
    }
  });
}

export const metadata = {
  name: 'tokens',
  version: '1.0.0',
  description: 'Token usage tracker using real ExtensionAPI',
  author: 'OMP Team'
};