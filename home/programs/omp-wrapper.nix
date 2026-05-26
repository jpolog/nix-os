{ pkgs, ollamaKeyPath ? null, ... }:

pkgs.writeShellApplication {
  name = "omp";
  runtimeInputs = with pkgs; [ bun nodejs docker curl ];

  text = ''
    # ── Discover locally available Ollama models ────────────────────────
    # Refresh the model catalog before launching so newly pulled models
    # appear as selectable overrides without manual config edits.
    ollama-discover 2>/dev/null || true

    OLLAMA_KEY_PATH="${toString ollamaKeyPath}"
    if [ -n "$OLLAMA_KEY_PATH" ] && [ -f "$OLLAMA_KEY_PATH" ]; then
      OLLAMA_API_KEY="$(cat "$OLLAMA_KEY_PATH")"
      export OLLAMA_API_KEY
    fi

    # Use a bash array for extra arguments to satisfy ShellCheck (SC2086)
    # and handle optional flags safely.
    extra_args=()
    if [ -n "''${PI_EXTRA_MOUNTS:-}" ]; then
       extra_args+=("--mount" "$PI_EXTRA_MOUNTS")
    fi

    # Launch the agent with strict project root enforcement
    exec bunx --bun @oh-my-pi/pi-coding-agent \
      --sandbox=docker:mom-sandbox \
      --project-root="$(pwd)" \
      "''${extra_args[@]}" \
      . "$@"
  '';
}