{ pkgs, ollamaKeyPath ? null, ... }:

{
  # Standard OMP (runs directly on host - no sandboxing)
  omp = pkgs.writeShellApplication {
    name = "omp";
    runtimeInputs = with pkgs; [ bun nodejs curl ];

    text = ''
      # ── Discover locally available Ollama models ────────────────────────
      ollama-discover 2>/dev/null || true

      OLLAMA_KEY_PATH="${toString ollamaKeyPath}"
      if [ -n "$OLLAMA_KEY_PATH" ] && [ -f "$OLLAMA_KEY_PATH" ]; then
        OLLAMA_API_KEY="$(cat "$OLLAMA_KEY_PATH")"
        export OLLAMA_API_KEY
      fi

      exec bunx --bun @oh-my-pi/pi-coding-agent "$@"
    '';
  };

  # Sandboxed OMP - runs in Docker with current directory mounted
  pp = pkgs.writeShellApplication {
    name = "pp";
    runtimeInputs = with pkgs; [ docker coreutils ];

    text = ''
      set -euo pipefail

      # Use argument as workspace, or current directory
      WORKSPACE="''${1:-$(pwd)}"
      WORKSPACE="$(cd "$WORKSPACE" 2>/dev/null && pwd)" || {
        echo "Error: Directory '$WORKSPACE' does not exist" >&2
        exit 1
      }

      # Check Docker is available
      if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker daemon is not running" >&2
        exit 1
      fi

      # Image name - can be overridden with PI_SANDBOX_IMAGE
      IMAGE="''${PI_SANDBOX_IMAGE:-oven/bun:alpine}"
      
      # Extra mounts - comma-separated list of host:container paths
      EXTRA_MOUNTS="''${PI_EXTRA_MOUNTS:-}"
      
      # Build docker mount args
      mount_args=(
        -v "$WORKSPACE:/workspace:rw"
        -v "$HOME/.omp:/root/.omp:rw"
      )
      
      # Add extra mounts if specified
      IFS=',' read -ra MOUNTS <<< "$EXTRA_MOUNTS"
      for mount in "''${MOUNTS[@]}"; do
        if [ -n "$mount" ]; then
          mount_args+=(-v "$mount")
        fi
      done

      # Pass through API keys
      env_args=(
        -e "ANTHROPIC_API_KEY=''${ANTHROPIC_API_KEY:-}"
        -e "OPENAI_API_KEY=''${OPENAI_API_KEY:-}"
        -e "GEMINI_API_KEY=''${GEMINI_API_KEY:-}"
        -e "OLLAMA_API_KEY=''${OLLAMA_API_KEY:-}"
        -e "GROQ_API_KEY=''${GROQ_API_KEY:-}"
        -e "XAI_API_KEY=''${XAI_API_KEY:-}"
        -e "OPENROUTER_API_KEY=''${OPENROUTER_API_KEY:-}"
        -e "COPILOT_GITHUB_TOKEN=''${COPILOT_GITHUB_TOKEN:-}"
      )

      # Run OMP in container
      exec docker run --rm -it \
        "''${mount_args[@]}" \
        "''${env_args[@]}" \
        -e PI_CODING_AGENT_DIR="/root/.omp/agent" \
        -w /workspace \
        --name "omp-$$" \
        "$IMAGE" \
        sh -c "bun x --bun @oh-my-pi/pi-coding-agent \"\$@\"" -- "$@"
    '';
  };
}