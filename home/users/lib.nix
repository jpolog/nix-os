{ lib, ... }:

{
  # Helper function to create user configurations
  mkUser = { username, fullName, email, profiles ? {}, extraConfig ? {} }: {
    imports = [
      ./shared.nix  # Shared configuration for all users
      ../profiles   # Import all home-manager profiles
    ];

    home = {
      username = username;
      homeDirectory = "/home/${username}";
      stateVersion = "25.11";
    };

    # User-specific git identity
    programs.git.settings.user = {
      name = fullName;
      email = email;
    };

    # Profile selections (user can override)
    home.profiles = lib.mkMerge [
      # Defaults
      {
        base.enable = lib.mkDefault true;
      }
      # User-specified profiles
      profiles
    ];
  } // extraConfig;
}
