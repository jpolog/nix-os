{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.desktop.enable {
    # XCompose for custom compose key sequences
    home.file.".XCompose".text = ''
      # Custom compose sequences
      include "%L"

        # Custom sequences (examples)
        <Multi_key> <e> <m> : "📧"  # email emoji
        <Multi_key> <h> <e> <a> <r> <t> : "❤️"  # heart emoji
        <Multi_key> <s> <t> <a> <r> : "⭐"  # star emoji
        <Multi_key> <c> <h> <e> <c> <k> : "✓"  # checkmark
        <Multi_key> <x> <m> <a> <r> <k> : "✗"  # x mark
        <Multi_key> <arrow> <l> : "←"
        <Multi_key> <arrow> <r> : "→"
        <Multi_key> <arrow> <u> : "↑"
        <Multi_key> <arrow> <d> : "↓"
        
      # Math symbols
      <Multi_key> <i> <n> <f> : "∞"
      <Multi_key> <s> <u> <m> : "∑"
      <Multi_key> <p> <i> : "π"
      <Multi_key> <d> <e> <l> <t> <a> : "Δ"
      
      # Add more custom sequences as needed
    '';

    # Set compose key in environment
    home.sessionVariables = {
      GTK_IM_MODULE = "xim";
      QT_IM_MODULE = "xim";
      XMODIFIERS = "@im=none";
    };
  };
}