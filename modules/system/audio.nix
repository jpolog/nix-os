{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.audio;
in
{
  options.modules.system.audio = {
    enable = mkEnableOption "Audio (PipeWire)";
  };

  config = mkIf cfg.enable {
    # PipeWire - Modern audio system
    security.rtkit.enable = true;
    
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      
      wireplumber.enable = true;
    };

    # Audio packages
    environment.systemPackages = with pkgs; [
      pavucontrol
      pulseaudio  # For pactl and pacmd
      pamixer
      playerctl
      easyeffects
    ];

    # Disable PulseAudio (PipeWire replaces it)
    services.pulseaudio.enable = false;
  };
}
