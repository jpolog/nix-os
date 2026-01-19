{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = lib.mkDefault false;
    
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    settings = {
      # Window
      remember_window_size = false;
      initial_window_width = 1200;
      initial_window_height = 800;
      window_padding_width = 10;
      
      # Tab bar
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
      
      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = 0;
      
      # Scrollback
      scrollback_lines = 10000;
      
      # URL
      url_style = "curly";
      
      # Bell
      enable_audio_bell = false;
      
      # Opacity
      background_opacity = "0.95";
      
      # Catppuccin Mocha theme colors
      foreground = "#CDD6F4";
      background = "#1E1E2E";
      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";
      
      # Cursor colors
      cursor = "#F5E0DC";
      cursor_text_color = "#1E1E2E";
      
      # URL underline color when hovering
      url_color = "#F5E0DC";
      
      # Kitty window border colors
      active_border_color = "#B4BEFE";
      inactive_border_color = "#6C7086";
      bell_border_color = "#F9E2AF";
      
      # Tab bar colors
      active_tab_foreground = "#11111B";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111B";
      
      # Colors (Catppuccin Mocha)
      color0 = "#45475A";
      color8 = "#585B70";
      color1 = "#F38BA8";
      color9 = "#F38BA8";
      color2 = "#A6E3A1";
      color10 = "#A6E3A1";
      color3 = "#F9E2AF";
      color11 = "#F9E2AF";
      color4 = "#89B4FA";
      color12 = "#89B4FA";
      color5 = "#F5C2E7";
      color13 = "#F5C2E7";
      color6 = "#94E2D5";
      color14 = "#94E2D5";
      color7 = "#BAC2DE";
      color15 = "#A6ADC8";
    };

    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+equal" = "increase_font_size";
      "ctrl+shift+minus" = "decrease_font_size";
      "ctrl+shift+backspace" = "restore_font_size";
    };
  };
}
