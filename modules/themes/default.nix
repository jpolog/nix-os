{ lib, ... }:

{
  imports = [
    ./catppuccin.nix
    ./rose-pine.nix
    ./thinknix.nix
  ];

  options.themes.active = lib.mkOption {
    type = lib.types.enum ["thinknix"]; #"catppuccin" "rose-pine" ];
    default = "thinknix";
    description = "The active system theme to apply via Stylix";
  };
}
