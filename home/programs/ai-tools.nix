{ config, lib, pkgs, osConfig ? null, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
  ollamaKeyPath = if osConfig != null then osConfig.sops.secrets.ollama_cloud_api_key.path else null;
  omp = pkgs.callPackage ./omp-wrapper.nix { inherit ollamaKeyPath; };
in

{
  options.programs.ai-tools = {
    enable = mkEnableOption "AI development tools";

    tools = {
      gemini-cli.enable = mkEnableOption "Gemini CLI";
      github-copilot-cli.enable = mkEnableOption "GitHub Copilot CLI";
      claude-code.enable = mkEnableOption "Claude Code";
      pi-coding-agent.enable = mkEnableOption "Pi Coding Agent (omp)";
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
    ]) ++ (lib.optionals cfg.tools.pi-coding-agent.enable [
      omp
    ]);

    home.file.".pi/agent" = mkIf cfg.tools.pi-coding-agent.enable {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/pi-agent-data";
    };

    home.file.".omp" = mkIf cfg.tools.pi-coding-agent.enable {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/pi-agent-data";
    };

    home.shellAliases = mkIf cfg.tools.pi-coding-agent.enable {
      pi = "omp";
    };
  };
}
