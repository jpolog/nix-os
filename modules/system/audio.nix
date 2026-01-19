{ config, pkgs, ... }:

{
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
  # Note: hardware.pulseaudio renamed to services.pulseaudio in NixOS 24.11+
  services.pulseaudio.enable = false;
}
