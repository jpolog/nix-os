{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image = ./assets/thinknix-wallpaper.svg; # Ensure this image is in the same directory
    polarity = "dark";

    # Custom "ThinkNix Red" Base16 Scheme
    # Inspired by ThinkPad aesthetics and Omarchy's dark/red themes
    base16Scheme = {
      base00 = "0a0a0a"; # Background (Deep Black/Carbon)
      base01 = "141414"; # Lighter Background (Status Bars)
      base02 = "252525"; # Selection Background (Dark Gray)
      base03 = "3d3d3d"; # Comments / Secondary Text (Medium Gray)
      base04 = "707070"; # Dark Foreground (Gray)
      base05 = "e0e0e0"; # Default Foreground (White-ish)
      base06 = "f0f0f0"; # Light Foreground (Bright White)
      base07 = "ffffff"; # Lightest Foreground

      base08 = "e60012"; # Red (Variables, XML Tags) - LENOVO RED
      base09 = "ff4d4d"; # Orange (Integers, Boolean) - Bright Red-Orange
      base0A = "ff6666"; # Yellow (Classes) - Soft Red
      base0B = "cc3333"; # Green (Strings) - Darker Red (Monochromatic vibe)
      base0C = "ff3333"; # Cyan (Regex) - Vibrant Red
      base0D = "ff1a1a"; # Blue (Functions) - Primary Accent Red
      base0E = "990000"; # Purple (Keywords) - Deep Red/Burgundy
      base0F = "4d0000"; # Brown (Deprecated) - Very Dark Red
    };

    # Force specific styling for better contrast
    opacity = {
      applications = 0.95;
      terminal = 0.90;
      desktop = 0.95;
      popups = 0.95;
    };

    # Font configuration to match the technical aesthetic
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}

