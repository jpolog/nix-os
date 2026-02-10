{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.home.programs.web-browsers;
in
{
  options.home.programs.web-browsers = {
    enable = mkEnableOption "web browsers";

    tridactyl = {
      enable = mkEnableOption "tridactyl extension";
    };
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      extensions =
        [
          # Add other extensions here
        ]
        ++ (
          if cfg.tridactyl.enable then
            [ { id = "caijckcgfhipflladkdkdjiaoilpkgbn"; } ]
          else
            [ ]
        );
    };
  };
}
