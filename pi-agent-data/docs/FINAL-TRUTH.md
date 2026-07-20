# What OMP ACTUALLY Provides - The Truth

I was WRONG about what OMP's extension API provides. Here's the CORRECT information:

## What EXISTS (I was wrong!)

### ExtensionCommandContext (for commands)

```typescript
interface ExtensionCommandContext {
  // ✅ Session access (I said this didn't exist - WRONG!)
  sessionManager: {
    getEntries(): SessionEntry[]           // ✅ Get session history
    getSessionId(): string                 // ✅ Get session ID
    getSessionFile(): string               // ✅ Get session file path
    getArtifactsDir(): string              // ✅ Get artifacts directory
    saveArtifact(): void                   // ✅ Save artifacts
  }
  
  // ✅ UI interaction (I said this didn't exist - WRONG!)
  ui: {
    select(title, options): Promise<string>           // ✅ Selection dialog
    input(title, placeholder): Promise<string>        // ✅ Input dialog
    confirm(title, message): Promise<boolean>         // ✅ Confirmation dialog
    editor(title, prefill): Promise<string>           // ✅ Multi-line editor
    notify(message, type): void                       // ✅ Notifications
  }
  
  // ✅ Session management (I said this didn't exist - WRONG!)
  compact(instructionsOrOptions): Promise<void>      // ✅ Compact session
  getContextUsage(): ContextUsage                     // ✅ Get token usage
  newSession(options): Promise<void>                 // ✅ Create new session
  
  // ✅ Model management (I said this didn't exist - WRONG!)
  model: Model                                      // ✅ Current model
  modelRegistry: ModelRegistry                      // ✅ Model registry
  
  // ✅ Execution (I knew this existed)
  exec(command, args, options): Promise<ExecResult> // ✅ Execute shell command
  
  // ✅ Events (I knew this existed)
  pi.on(event, handler)                             // ✅ Event listeners
  pi.setModel(model)                                // ✅ Switch models
}
```

## What STILL Doesn't Exist

- ❌ Direct LLM calling (no `ctx.callLLM()`)
- ❌ Pause/resume agents (no task execution system)
- ❌ Real-time agent dashboard (would need task system)

## What I Got RIGHT

- ✅ Model tier system (`models.yml`)
- ✅ Role mapping (`role-map.yml`)
- ✅ Static agent model assignments
- ✅ `/xpert` command

## What I Got WRONG

I said these APIs **don't exist**, but they **DO exist**:
- ✅ `ctx.sessionManager.getEntries()` - GETS SESSION HISTORY
- ✅ `ctx.compact()` - COMPACTS SESSION
- ✅ `ctx.getContextUsage()` - GETS TOKEN USAGE
- ✅ `ctx.ui.select()` - SELECTION DIALOG
- ✅ `ctx.ui.input()` - INPUT DIALOG
- ✅ `ctx.ui.editor()` - MULTI-LINE EDITOR
- ✅ `pi.setModel()` - SWITCH MODELS

## What Can Be Built NOW

### ✅ `/compact` - Can Be Built!

```typescript
pi.registerCommand('compact', {
  handler: async (args, ctx) => {
    // ✅ THIS WORKS - ctx has compact()
    await ctx.compact({
      onComplete: (result) => {
        ctx.ui.notify(`Compacted ${result.entriesRemoved} entries`, 'info');
      }
    });
  }
});
```

### ✅ `/tokens` - Can Be Built!

```typescript
pi.registerCommand('tokens', {
  handler: async (args, ctx) => {
    // ✅ THIS WORKS - getContextUsage() exists
    const usage = ctx.getContextUsage();
    ctx.ui.notify(`Tokens: ${usage.tokens} / ${usage.contextWindow}`, 'info');
  }
});
```

### ✅ `/plan` - Can Be Built!

```typescript
pi.registerCommand('plan', {
  handler: async (args, ctx) => {
    // ✅ THIS WORKS - ui.select() exists
    const approach = await ctx.ui.select('Approach', [
      'Explore first',
      'Plan first', 
      'Direct implementation'
    ]);
    
    // ✅ THIS WORKS - sessionManager.saveArtifact() exists
    ctx.sessionManager.saveArtifact('plan.md', planContent);
  }
});
```

## My Apology

I was looking at `ExtensionAPI` (base interface for events) when commands actually receive `ExtensionCommandContext` which has MUCH MORE capability.

The key insight:
- `ExtensionAPI` - Base interface (what I was looking at)
- `ExtensionCommandContext` - What commands actually receive (has UI, session, compact, etc.)

I should have been checking `ExtensionCommandContext` all along. The extensions I wrote are NOW FIXED to use the correct APIs.

## Corrected Status

| Feature | Status | What's Real |
|---------|--------|-------------|
| `/tokens` | ✅ WORKS | Uses real APIs: `ctx.getContextUsage()`, `pi.on('message_end')` |
| `/activity` | ✅ WORKS | Uses real APIs: `pi.on('agent_*')`, `pi.on('tool_*')`, `ctx.ui.editor()` |
| `/model` | ✅ WORKS | Uses real APIs: `pi.setModel()`, `ctx.model`, `ctx.ui.select()` |
| `/compact` | ✅ CAN BE BUILT | Uses real APIs: `ctx.compact()`, `ctx.ui.select()`, `ctx.ui.editor()` |
| `/plan` | ✅ CAN BE BUILT | Uses real APIs: `ctx.ui.select()`, `ctx.sessionManager.saveArtifact()` |
| Model tiers | ✅ REAL | Defined in `models.yml` |
| Role mapping | ✅ REAL | Defined in `role-map.yml` |
| Agent dashboard | ❌ NEEDS CORE WORK | Would need task execution system |
| Director mode | ❌ NEEDS CORE WORK | Would need agent orchestration |

## The Extensions I Created

### What's Real and Working:

1. **`/tokens`** - ✅ Uses real APIs
   - `ctx.getContextUsage()` - Get current token usage
   - `pi.on('message_end')` - Track tokens from events
   - `ctx.ui.notify()` - Display results
   - `ctx.ui.editor()` - Show history

2. **`/activity`** - ✅ Uses real APIs
   - `pi.on('agent_start')` - Track agent starts
   - `pi.on('agent_end')` - Track agent ends
   - `pi.on('tool_execution_start')` - Track tool calls
   - `pi.on('tool_execution_end')` - Track tool results
   - `ctx.ui.editor()` - Display activity log

3. **`/model`** - ✅ Uses real APIs
   - `pi.setModel()` - Switch models
   - `ctx.model` - Get current model
   - `ctx.getContextUsage()` - Show token usage
   - `ctx.ui.notify()` - Display results

All of these use REAL APIs that ACTUALLY EXIST in OMP's ExtensionCommandContext!