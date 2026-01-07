{ config, lib, pkgs, ... }:

with lib;

{
  options.profiles.base = {
    enable = mkEnableOption "base system profile" // { default = true; };
  };

  config = mkIf config.profiles.base.enable {
    # Essential packages for all systems
    environment.systemPackages = with pkgs; [
      vim
      wget
      curl
      git
      htop
      btop
      neofetch
      pciutils
      usbutils
      lshw
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
