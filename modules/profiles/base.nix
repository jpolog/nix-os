{ config, lib, pkgs, ... }:

with lib;

{
  options.profiles.base = {
    enable = mkEnableOption "base system profile" // { default = true; };
  };

  config = mkIf config.profiles.base.enable {
    # Essential packages for all systems
    environment.systemPackages = with pkgs; [
      # Editors
      vim
      nano
      
      # Network tools
      wget
      curl
      
      # Version control
      git
      
      # System monitoring
      htop
      btop
      
      # System information
      neofetch
      pciutils   # lspci
      usbutils   # lsusb
      lshw       # Hardware lister
      dmidecode  # DMI table decoder
      
      # File management
      tree
      eza
      fd
      ripgrep
      bat
      
      # Archive tools
      unzip
      zip
      p7zip
    ];

    # Enable ZSH globally
    programs.zsh.enable = true;

    # Basic nix settings
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };
}
