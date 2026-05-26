{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "kde") {

    # -------------------------------------------------------------------------
    # Wayland compatibility for third-party apps on KDE Plasma (Wayland session)
    #
    # KDE sets XDG_SESSION_TYPE=wayland and XDG_CURRENT_DESKTOP=KDE itself via
    # PAM/systemd, but third-party toolkits (Electron, GTK, SDL) need extra hints
    # to use the native Wayland backend instead of falling back to XWayland.
    # XWayland works but causes blurry HiDPI rendering, unresponsive windows,
    # and broken clipboard in some apps (Plex Desktop, Discord, Chrome, etc.).
    # -------------------------------------------------------------------------
    home.sessionVariables = {
      # Electron / Chromium-based apps (Plex Desktop, Discord, Bitwarden,
      # Google Chrome, VS Code, …): use native Wayland/Ozone backend.
      NIXOS_OZONE_WL              = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";  # "auto" = Wayland when available

      # GTK apps: prefer Wayland, fall back to X11, then anything
      GDK_BACKEND = "wayland,x11,*";

      # Qt/KDE apps: prefer Wayland, fall back to XCB (X11)
      # KDE usually injects this itself, but being explicit avoids edge cases.
      QT_QPA_PLATFORM = "wayland;xcb";

      # SDL2/SDL3 apps (games, some media players): use Wayland
      SDL_VIDEODRIVER = "wayland";

      # Java/AWT apps (AutoFirma, etc.): force XWayland — Java's AWT
      # has no native Wayland backend; XWayland is the correct path for it.
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
