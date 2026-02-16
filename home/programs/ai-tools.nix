{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
in

{
  options.programs.ai-tools = {
    enable = mkEnableOption "AI development tools";

    tools = {
      gemini-cli.enable = mkEnableOption "Gemini CLI";
      github-copilot-cli.enable = mkEnableOption "GitHub Copilot CLI";
      claude-code.enable = mkEnableOption "Claude Code";
      goose.enable = mkEnableOption "Goose CLI agent";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
    ] ++ (lib.optionals cfg.tools.gemini-cli.enable [
      gemini-cli
    ]) ++ (lib.optionals cfg.tools.github-copilot-cli.enable [
      github-copilot-cli
    ]) ++ (lib.optionals cfg.tools.claude-code.enable [
      claude-code
    ]) ++ (lib.optionals cfg.tools.goose.enable [
      goose-cli
    ]);

    home.file.".config/goose/config.yaml" = mkIf cfg.tools.goose.enable {
      text = ''
        GOOSE_PROVIDER: ollama
        GOOSE_MODEL: qwen3-coder-next
        OLLAMA_HOST: http://localhost:11434
        extensions:
          developer:
            enabled: true
            type: builtin
            name: developer
            description: Code editing and shell access
            display_name: Developer Tools
            timeout: 300
            bundled: true
            available_tools: []
          extensionmanager:
            enabled: true
            type: platform
            name: Extension Manager
            description: Enable extension management tools for discovering, enabling, and disabling extensions
            bundled: true
            available_tools: []
          chatrecall:
            enabled: true
            type: platform
            name: chatrecall
            description: Search past conversations and load session summaries for contextual memory
            bundled: true
            available_tools: []
          code_execution:
            enabled: true
            type: platform
            name: code_execution
            description: Execute JavaScript code in a sandboxed environment
            bundled: true
            available_tools: []
          skills:
            enabled: true
            type: platform
            name: skills
            description: Load and use skills from relevant directories
            bundled: true
            available_tools: []
          todo:
            enabled: true
            type: platform
            name: todo
            description: Enable a todo list for goose so it can keep track of what it is doing
            bundled: true
            available_tools: []
          computercontroller:
            enabled: true
            type: builtin
            name: computercontroller
            description: controls for webscraping, file caching, and automations
            display_name: Computer Controller
            timeout: 300
            bundled: true
            available_tools: []
          autovisualiser:
            enabled: true
            type: builtin
            name: autovisualiser
            description: Data visualisation and UI generation tools
            display_name: Auto Visualiser
            timeout: 300
            bundled: true
            available_tools: []
      '';
    };
  };
}
