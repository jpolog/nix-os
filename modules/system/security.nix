{ config, pkgs, ... }:

{
  # Security and authentication
  security = {
    polkit.enable = true;
    pam.services.hyprlock = {};
    
    # Sudo configuration
    sudo = {
      enable = true;
      extraConfig = ''
        Defaults timestamp_timeout=30
        Defaults pwfeedback
      '';
    };
  };

  # Fingerprint reader (fprintd)
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  # PAM configuration for fingerprint
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
  };

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Security packages
  environment.systemPackages = with pkgs; [
    fprintd
    polkit_gnome
  ];
}
