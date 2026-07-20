# OMP Extensions

This directory contains extensions for Oh My Pi (OMP) that add slash commands and interactive features.

## Available Extensions

### `/compact` - Conversation Compaction

Compacts conversation history with progress tracking. Works with any LLM.

```bash
/compact                              # Compact with defaults (hybrid strategy, preserve 10 messages)
/compact --preserve 20               # Preserve last 20 messages
/compact --strategy summary          # Use summary strategy
/compact --model claude-3-5-sonnet   # Use specific model
```

**Features:**
- Real-time progress bar
- Multiple compaction strategies (summary, extract, hybrid)
- Token counting and statistics
- Context preservation
- Model-agnostic

**Strategies:**
- `summary`: Narrative summary of conversation
- `extract`: Bullet-point extraction of key facts
- `hybrid`: Combined approach (default)

### `/plan` - Interactive Planning

Creates execution plans with clarification questions. Works with any LLM.

```bash
/plan "Create a REST API with authentication"
/plan "Fix the bug in login" --skip-questions
/plan "Design database schema" --model claude-3-5-sonnet
```

**Features:**
- Interactive Q&A with hjkl navigation
- Multiple question types (single choice, multiple choice, free-form)
- Plan refinement based on answers
- Step-by-step execution with dependency management
- Execution options (execute, compact-then-execute, modify, save)
- Model-agnostic

**Workflow:**
1. Generate draft plan with questions
2. Ask clarification questions
3. Refine plan with answers
4. Present execution options
5. Execute or save plan

**Question Types:**
- `single`: Select one option
- `multiple`: Select multiple options
- `text`: Free-form input

## Extension Development

Extensions implement the `ExtensionAPI` interface:

```typescript
interface ExtensionAPI {
  // Command registration
  registerCommand(command: Command): void;
  
  // Conversation history
  getHistory(): Promise<Message[]>;
  replaceHistory(messages: Message[]): Promise<void>;
  
  // LLM interaction
  callLLM(request: LLMRequest): Promise<string>;
  getCurrentModel(): Promise<string>;
  countTokens(content: string): Promise<number>;
  
  // Display
  display(message: DisplayMessage): Promise<void>;
  displayProgress(progress: Progress): Promise<string>;
  updateProgress(id: string, progress: Progress): Promise<void>;
  
  // User input
  promptInput(options: InputOptions): Promise<string>;
  promptSelect(options: SelectOptions): Promise<string>;
  promptMultiSelect(options: MultiSelectOptions): Promise<string[]>;
  promptConfirm(options: ConfirmOptions): Promise<boolean>;
  
  // Context management
  setContext(key: string, value: any): Promise<void>;
  getContext(key: string): Promise<any>;
  clearContext(key: string): Promise<void>;
  
  // Command execution
  executeCommand(command: string): Promise<void>;
  executeStep(id: string, title: string, description: string): Promise<void>;
  isStepComplete(id: string): Promise<boolean>;
  markStepComplete(id: string): Promise<void>;
  waitForDependencies(ids: string[]): Promise<void>;
  
  // File operations
  saveFile(filename: string, content: string): Promise<string>;
  loadFile(path: string): Promise<string>;
}
```

### Creating a New Extension

1. Create a directory in `extensions/`:
```bash
mkdir -p extensions/my-extension
```

2. Create `index.ts`:
```typescript
import { ExtensionAPI } from '../../types';

export default function myExtension(pi: ExtensionAPI) {
  pi.registerCommand({
    command: '/my-command',
    description: 'Description of my command',
    usage: '/my-command [options]',
    
    handler: async (ctx, args) => {
      // Your implementation here
      await pi.display({
        type: 'message',
        content: 'Hello from my extension!',
        style: 'info'
      });
    }
  });
}

export const metadata = {
  name: 'my-extension',
  version: '1.0.0',
  description: 'Description of my extension',
  author: 'Your Name'
};
```

3. Create `README.md`:
```markdown
# My Extension

Description and usage examples.
```

4. Register in `config.yml` (if needed):
```yaml
extensions:
  - my-extension
```

## Model Agnostic Design

Both extensions work with **any LLM** configured in OMP's `models.local.json`:

- Claude models (claude-3-5-sonnet, claude-3-opus, etc.)
- OpenAI models (gpt-4, gpt-3.5-turbo, etc.)
- Local models via Ollama
- Custom endpoints

The extensions use OMP's `callLLM` API which:
- Handles model selection automatically
- Uses the currently configured model by default
- Falls back to alternative models if needed
- Manages token limits and context windows

## Comparison to Claude Code Features

| Feature | Claude Code | OMP Extensions |
|---------|-------------|----------------|
| `/compact` command | ✓ | ✓ |
| Progress bar | ✓ | ✓ |
| Multiple strategies | ✗ | ✓ |
| `/plan` command | ✓ | ✓ |
| Interactive Q&A | ✓ | ✓ |
| hjkl navigation | ✓ | ✓ |
| Plan refinement | ✓ | ✓ |
| Execution options | ✓ | ✓ |
| Model-agnostic | ✗ | ✓ |
| Compact and execute | ✓ | ✓ |
| Save/load plans | ✓ | ✓ |
| Dependency management | ✓ | ✓ |

**Key Advantage**: OMP extensions work with **any LLM**, not just Claude models. You can use GPT-4, local models, or any model configured in OMP.

## Testing

Extensions can be tested in the OMP REPL:

```bash
# Start OMP
omp

# Test /compact
/compact

# Test /plan
/plan "Test task"

# Check extension is loaded
/extensions
```

## Debugging

Enable debug logging:

```bash
export OMP_DEBUG=extensions
omp
```

Check logs:

```bash
tail -f ~/.omp/logs/omp.log | grep -E "(compact|plan)"
```

## Future Enhancements

Potential improvements for future versions:

### `/compact`:
- [ ] Auto-compact based on token threshold
- [ ] Smart preservation of important messages
- [ ] Compression ratio optimization
- [ ] Custom summarization prompts

### `/plan`:
- [ ] Plan templates for common tasks
- [ ] Collaborative planning (multiple users)
- [ ] Plan versioning and rollback
- [ ] Integration with external tools (git, npm, etc.)
- [ ] Parallel step execution
- [ ] Plan analytics and metrics

## Contributing

To contribute:

1. Fork the repository
2. Create a feature branch
3. Add/modify extensions in `extensions/`
4. Add tests
5. Update documentation
6. Submit a pull request

## License

Part of the Oh My Pi project.