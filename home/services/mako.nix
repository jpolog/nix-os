{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    
    # Appearance
    backgroundColor = "#1e1e2eff";
    textColor = "#cdd6f4ff";
    borderColor = "#89b4faff";
    progressColor = "over #313244ff";
    
    # Layout
    width = 350;
    height = 150;
    margin = "10";
    padding = "15";
    borderSize = 2;
    borderRadius = 10;
    
    # Behavior
    defaultTimeout = 5000;
    ignoreTimeout = false;
    
    # Position
    anchor = "top-right";
    
    # Font
    font = "JetBrainsMono Nerd Font 11";
    
    # Icons
    icons = true;
    maxIconSize = 48;
    
    # Grouping
    groupBy = "app-name";
    
    # Extra config
    extraConfig = ''
      [urgency=low]
      border-color=#94e2d5ff
      default-timeout=3000

      [urgency=normal]
      border-color=#89b4faff
      default-timeout=5000

      [urgency=high]
      border-color=#f38ba8ff
      default-timeout=0

      [app-name=Spotify]
      border-color=#a6e3a1ff
    '';
  };
}
