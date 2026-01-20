{ lib, ... }:

{
  imports = [
    ./catppuccin.nix
    ./rose-pine.nix
  ];

  options.themes.active = lib.mkOption {
    type = lib.types.enum [ "catppuccin" "rose-pine" ];
    default = "catppuccin";
    description = "The active system theme to apply via Stylix";
  };
}
