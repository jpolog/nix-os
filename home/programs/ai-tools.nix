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
    ]);
  };
}
