{ lib, ... }:

{
  # Helper function to create user configurations
  mkUser = { username, fullName, email, profiles ? {}, extraConfig ? {} }: {
    imports = [
      ./shared.nix  # Shared configuration for all users
      ../profiles   # Import all home-manager profiles
      extraConfig   # Merge extraConfig as a module
    ];

    home = {
      username = username;
      homeDirectory = "/home/${username}";
      # stateVersion is handled in shared.nix
    };

    # User-specific git identity
    programs.git = {
      enable = true;
      settings = {
        user.name = fullName;
        user.email = email;
      };
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
  };
}
