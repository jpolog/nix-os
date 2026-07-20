/**
 * Agent Activity Monitor - ACTUAL WORKING VERSION
 * 
 * Monitors agent activity using real ExtensionAPI events.
 * Uses REAL APIs: pi.on('agent_*'), pi.on('tool_*'), ctx.ui.*
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

interface ActivityEvent {
  type: 'agent_start' | 'agent_end' | 'tool_start' | 'tool_end' | 'message';
  timestamp: number;
  agent?: string;
  tool?: string;
  details?: string;
}

export default function activityMonitorExtension(pi: ExtensionAPI) {
  const activityLog: ActivityEvent[] = [];
  const MAX_LOG_SIZE = 100;
  
  // Track agent lifecycle
  pi.on('agent_start', (event) => {
    addActivity({
      type: 'agent_start',
      agent: event.agent,
      details: event.task
    });
  });
  
  pi.on('agent_end', (event) => {
    addActivity({
      type: 'agent_end',
      agent: event.agent,
      details: event.status
    });
  });
  
  // Track tool execution
  pi.on('tool_execution_start', (event) => {
    const params = event.parameters ? JSON.stringify(event.parameters).substring(0, 50) : 'no params';
    addActivity({
      type: 'tool_start',
      tool: event.toolName,
      details: params
    });
  });
  
  pi.on('tool_execution_end', (event) => {
    addActivity({
      type: 'tool_end',
      tool: event.toolName,
      details: event.result ? '✓' : '✗'
    });
  });
  
  // Track messages
  pi.on('message_start', (event) => {
    addActivity({
      type: 'message',
      details: event.role
    });
  });
  
  function addActivity(event: Omit<ActivityEvent, 'timestamp'>) {
    activityLog.push({
      ...event,
      timestamp: Date.now()
    });
    
    // Keep log bounded
    if (activityLog.length > MAX_LOG_SIZE) {
      activityLog.shift();
    }
  }
  
  pi.registerCommand('activity', {
    description: 'Show recent agent activity',
    handler: async (args, ctx) => {
      const subcommand = args.trim().toLowerCase();
      
      if (subcommand === 'clear') {
        activityLog.length = 0;
        ctx.ui.notify('Activity log cleared', 'info');
        return;
      }
      
      if (subcommand === 'stats') {
        // Count by type
        const counts = {
          agent_starts: activityLog.filter(e => e.type === 'agent_start').length,
          agent_ends: activityLog.filter(e => e.type === 'agent_end').length,
          tool_starts: activityLog.filter(e => e.type === 'tool_start').length,
          tool_ends: activityLog.filter(e => e.type === 'tool_end').length,
          messages: activityLog.filter(e => e.type === 'message').length
        };
        
        // Tools by frequency
        const toolCounts: Record<string, number> = {};
        activityLog
          .filter(e => e.type === 'tool_start' && e.tool)
          .forEach(e => {
            toolCounts[e.tool!] = (toolCounts[e.tool!] || 0) + 1;
          });
        
        const toolBreakdown = Object.entries(toolCounts)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 5)
          .map(([tool, count]) => `  ${tool}: ${count}`)
          .join('\n');
        
        const message = `📊 Activity Statistics

By type:
  Agent starts: ${counts.agent_starts}
  Agent ends: ${counts.agent_ends}
  Tool starts: ${counts.tool_starts}
  Tool ends: ${counts.tool_ends}
  Messages: ${counts.messages}

Top tools:
${toolBreakdown || '  (no data)'}`;
        
        ctx.ui.notify(message, 'info');
        return;
      }
      
      // Default: show recent activity
      const recent = activityLog.slice(-20);
      const timeStr = (ts: number) => {
        const d = new Date(ts);
        return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}:${d.getSeconds().toString().padStart(2, '0')}`;
      };
      
      const output = recent.map(e => {
        const time = timeStr(e.timestamp);
        switch (e.type) {
          case 'agent_start':
            return `${time} ▶️  Agent start: ${e.agent}${e.details ? ` (${e.details})` : ''}`;
          case 'agent_end':
            return `${time} ✅ Agent end: ${e.agent}`;
          case 'tool_start':
            return `${time} 🔧 Tool start: ${e.tool}${e.details ? ` ${e.details}` : ''}`;
          case 'tool_end':
            return `${time} ${e.details === '✓' ? '✓' : '✗'} Tool end: ${e.tool}`;
          case 'message':
            return `${time} 💬 Message: ${e.details}`;
          default:
            return `${time} ❓ ${e.type}`;
        }
      }).join('\n');
      
      await ctx.ui.editor(
        `Recent Activity (${activityLog.length} events)`,
        output || '(no activity yet)'
      );
    }
  });
}

export const metadata = {
  name: 'activity',
  version: '1.0.0',
  description: 'Agent activity monitor using real ExtensionAPI',
  author: 'OMP Team'
};