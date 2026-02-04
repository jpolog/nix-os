{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.github-copilot;
  
  # Create copilot config that uses the token from secrets
  copilotConfigJson = pkgs.writeText "copilot-config.json" (builtins.toJSON {
    banner = "never";
    render_markdown = true;
    theme = "auto";
    trusted_folders = [
      "/etc/nixos"
      "/home/${cfg.user}"
    ];
    last_logged_in_user = {
      host = "https://github.com";
      login = cfg.githubUsername;
    };
    logged_in_users = [
      {
        host = "https://github.com";
        login = cfg.githubUsername;
      }
    ];
  });
  
  # Script to setup copilot config with token from secrets
  setupCopilotConfig = pkgs.writeShellScript "setup-copilot-config" ''
    CONFIG_DIR="/home/${cfg.user}/.config/.copilot"
    CONFIG_FILE="$CONFIG_DIR/config.json"
    TOKEN_FILE="${config.sops.secrets.github_copilot_token.path}"
    
    # Create directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    
    # Read the token from sops secret
    if [ -f "$TOKEN_FILE" ]; then
      TOKEN=$(cat "$TOKEN_FILE")
      
      # Create config with token injected
      ${pkgs.jq}/bin/jq \
        --arg token "$TOKEN" \
        --arg user "${cfg.githubUsername}" \
        '.copilot_tokens = {"https://github.com:\($user)": $token}' \
        ${copilotConfigJson} > "$CONFIG_FILE"
      
      # Set proper permissions
      chmod 600 "$CONFIG_FILE"
      chown ${cfg.user}:users "$CONFIG_FILE"
    fi
  '';
  
in
{
  options.services.github-copilot = {
    enable = mkEnableOption "GitHub Copilot CLI configuration with sops";
    
    user = mkOption {
      type = types.str;
      default = "jpolo";
      description = "User to configure GitHub Copilot for";
    };
    
    githubUsername = mkOption {
      type = types.str;
      default = "jpolog";
      description = "GitHub username for Copilot authentication";
    };
  };
  
  config = mkIf cfg.enable {
    # Declare the sops secret
    sops.secrets.github_copilot_token = {
      owner = cfg.user;
      mode = "0400";
    };
    
    # Setup systemd service to configure copilot on boot
    systemd.services.setup-copilot-config = {
      description = "Setup GitHub Copilot configuration with token from secrets";
      wantedBy = [ "multi-user.target" ];
      after = [ "sops-nix.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        ExecStart = setupCopilotConfig;
        RemainAfterExit = true;
      };
    };
    
    # Create a wrapper script that works with sudo
    # This fixes the "sudo copilot" issue
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "copilot-sudo" ''
        # Preserve user's copilot config when using sudo
        USER_CONFIG="/home/${cfg.user}/.config/.copilot"
        
        if [ "$EUID" -eq 0 ] && [ -d "$USER_CONFIG" ]; then
          # Running as root via sudo, use the user's config
          export HOME="/home/${cfg.user}"
        fi
        
        exec ${pkgs.github-copilot-cli}/bin/copilot "$@"
      '')
    ];
    
    # Add alias to the shell config for convenience
    programs.zsh.shellAliases = {
      copilot = "copilot-sudo";
    };
  };
}
