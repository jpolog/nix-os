{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.research = {
    enable = mkEnableOption "research tools profile";

    latex = {
      enable = mkEnableOption "LaTeX full suite" // { default = true; };
    };
    
    tools = {
      enable = mkEnableOption "research auxiliary tools" // { default = true; };
    };

    visualization = {
      enable = mkEnableOption "PDF visualization and sync" // { default = true; };
    };
    
    diagrams = {
      enable = mkEnableOption "professional diagramming tools (Inkscape)" // { default = true; };
    };
  };

  config = mkIf config.home.profiles.research.enable {
    home.packages = mkMerge [
      # LaTeX Suite
      (mkIf config.home.profiles.research.latex.enable [
        pkgs.texlive.combined.scheme-full
      ])

      # Research Tools
      (mkIf config.home.profiles.research.tools.enable [
        pkgs.pandoc
        pkgs.zotero
        pkgs.obsidian
      ])
      
      # Diagramming Tools
      (mkIf config.home.profiles.research.diagrams.enable [
        pkgs.inkscape
      ])
      
      # PDF Visualization
      (mkIf config.home.profiles.research.visualization.enable [
        pkgs.zathura
        pkgs.sioyek # Another excellent PDF viewer for research
      ])
    ];

    # Configuration for Zathura (synctex support)
    programs.zathura = mkIf config.home.profiles.research.visualization.enable {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        synctex = true;
        synctex-editor-command = "nvim --headless -c \"VimtexInverseSearch %{line} '%{input}'\"";
      };
    };
  };
}
