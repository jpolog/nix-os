{ config, pkgs, ... }:

{
  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Environment variables for development
  environment.sessionVariables = {
    DIRENV_LOG_FORMAT = "";  # Silence direnv
  };

  # System-wide direnv configuration
  environment.etc."direnvrc".text = ''
    # Add any global direnvrc configuration here
    source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
  '';
}
