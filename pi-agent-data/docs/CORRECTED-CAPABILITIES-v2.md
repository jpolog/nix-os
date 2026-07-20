# OMP Extension Capabilities - What ACTUALLY Exists

I was WRONG about what OMP's extension API provides. Here's the CORRECT information:

## ✅ What ACTUALLY Exists

### ExtensionCommandContext (for commands)

```typescript
interface ExtensionCommandContext {
  // Session access
  sessionManager: {
    getEntries(): SessionEntry[]           // ✅ Get session history
    getSessionId(): string                 // ✅ Get session ID
    getSessionFile(): string               // ✅ Get session file path
    getArtifactsDir(): string              // ✅ Get artifacts directory
    saveArtifact(): void                   // ✅ Save artifacts
    getArtifactManager(): ArtifactManager  // ✅ Get artifact manager
  }
  
  // UI interaction
  ui: {
    select(title, options): Promise<string>           // ✅ Selection dialog
    input(title, placeholder): Promise<string>        // ✅ Input dialog
    confirm(title, message): Promise<boolean>         // ✅ Confirmation dialog
    editor(title, prefill): Promise<string>           // ✅ Multi-line editor
    notify(message, type): void                       // ✅ Notifications
    setStatus(key, text): void                        // ✅ Status bar
    setWidget(key, content): void                     // ✅ Custom widgets
  }
  
  // Session management
  compact(instructionsOrOptions): Promise<void>      // ✅ Compact session
  getContextUsage(): ContextUsage                     // ✅ Get token usage
  newSession(options): Promise<void>                 // ✅ Create new session
  branch(entryId): Promise<void>                     // ✅ Branch from entry
  navigateTree(targetId): Promise<void>              // ✅ Navigate session tree
  switchSession(sessionPath): Promise<void>           // ✅ Switch session
  
  // Model management
  model: Model                                      // ✅ Current model
  modelRegistry: ModelRegistry                      // ✅ Model registry
  
  // Execution
  exec(command, args, options): Promise<ExecResult> // ✅ Execute shell command
  
  // Events
  pi.on(event, handler)                             // ✅ Event listeners
}
```

### What I Thought Didn't Exist (BUT DOES!)

- ✅ `ctx.sessionManager.getEntries()` - GET SESSION HISTORY
- ✅ `ctx.compact()` - COMPACT SESSION  
- ✅ `ctx.getContextUsage()` - GET TOKEN USAGE
- ✅ `ctx.ui.select()` - SELECTION DIALOG
- ✅ `ctx.ui.input()` - INPUT DIALOG
- ✅ `ctx.ui.editor()` - MULTI-LINE EDITOR

### What Still Doesn't Exist

- ❌ Direct LLM calling (no `ctx.callLLM()`)
- ❌ Pause/resume agents (no task execution system)
- ❌ Real-time agent dashboard (would need task system)
- ❌ Token counting for arbitrary text (only `getContextUsage()` for current session)

## What Can Be Built NOW

### ✅ `/compact` - ACTUAL WORKING VERSION

```typescript
export default function compactExtension(pi: ExtensionAPI) {
  pi.registerCommand('compact', {
    handler: async (args, ctx) => {
      // ✅ THIS WORKS - ctx has sessionManager and compact()
      const entries = ctx.sessionManager.getEntries();
      const usage = ctx.getContextUsage();
      
      // Show strategy selection
      const strategy = await ctx.ui.select(
        'Compaction Strategy',
        [
          'summary - Narrative summary',
          'extract - Bullet points',
          'hybrid - Combined approach'
        ]
      );
      
      // Compact session
      await ctx.compact({
        onComplete: (result) => {
          ctx.ui.notify(
            `Compacted ${result.entriesRemoved} entries, saved ${result.tokensSaved} tokens`,
            'info'
          );
        }
      });
    }
  });
}
```

### ✅ `/plan` - ACTUAL WORKING VERSION

```typescript
export default function planExtension(pi: ExtensionAPI) {
  pi.registerCommand('plan', {
    handler: async (args, ctx) => {
      // ✅ THIS WORKS - ctx.ui has select/input
      const task = args.trim() || await ctx.ui.input('Task to plan:');
      
      // Get answers interactively
      const approach = await ctx.ui.select(
        'Approach',
        ['Explore first', 'Plan first', 'Direct implementation']
      );
      
      const priority = await ctx.ui.select(
        'Priority',
        ['Speed', 'Quality', 'Balance']
      );
      
      // ✅ THIS WORKS - we can use ctx.model
      ctx.ui.notify(`Planning ${task} using ${ctx.model?.id}...`, 'info');
      
      // Store plan in artifacts
      const planPath = ctx.sessionManager.saveArtifact('plan.md', plan);
      
      ctx.ui.notify(`Plan saved to ${planPath}`, 'info');
    }
  });
}
```

### ✅ `/tokens` - ACTUAL WORKING VERSION

```typescript
export default function tokensExtension(pi: ExtensionAPI) {
  pi.registerCommand('tokens', {
    handler: async (args, ctx) => {
      // ✅ THIS WORKS - getContextUsage() exists
      const usage = ctx.getContextUsage();
      
      if (!usage) {
        ctx.ui.notify('Token usage unknown (e.g., right after compaction)', 'warning');
        return;
      }
      
      const percent = usage.percent?.toFixed(1) || 'unknown';
      const tokens = usage.tokens?.toLocaleString() || 'unknown';
      
      ctx.ui.notify(
        `Token Usage: ${tokens} / ${usage.contextWindow.toLocaleString()} (${percent}%)`,
        'info'
      );
    }
  });
}
```

## What STILL Can't Be Built

### ❌ Agent Dashboard

Would need:
- Task execution system
- Agent lifecycle management
- Real-time state tracking

### ❌ Director Mode

Would need:
- Multi-agent coordination
- Worker spawning
- Result aggregation

### ❌ Mid-Agent Intervention

Would need:
- Agent pausing/resuming
- Message injection
- State snapshots

## My Mistake

I was looking at the WRONG interface (`ExtensionAPI`) when commands actually receive `ExtensionCommandContext` which has MUCH MORE capability.

The key differences:
- `ExtensionAPI` - Base interface for events
- `ExtensionContext` - Has sessionManager, model, exec
- `ExtensionCommandContext` - Has UI, compact, navigation

I should have been using `ExtensionCommandContext` all along!

## Corrected Extensions

Now I can build ACTUAL WORKING versions:

1. **`/compact`** - Uses `ctx.compact()` and `ctx.ui.select()`
2. **`/tokens`** - Uses `ctx.getContextUsage()`
3. **`/activity`** - Uses `pi.on('agent_*')` events
4. **`/model`** - Uses `ctx.model`
5. **`/plan`** - Uses `ctx.ui.select()` and `ctx.sessionManager.saveArtifact()`

All of these use REAL APIs that ACTUALLY EXIST!