{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.cli.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      
      settings = {
        add_newline = true;
        
        format = "$directory$nix_shell$git_branch$git_status$character";
        
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };

        username = {
          style_user = "bold blue";
          style_root = "bold red";
          format = "[$user]($style) ";
          show_always = false;
        };

        hostname = {
          ssh_only = true;
          format = "on [$hostname](bold yellow) ";
        };

        directory = {
          truncation_length = 2;
          truncate_to_repo = true;
          style = "bold cyan";
          format = "[$path]($style) ";
        };

        git_branch = {
          symbol = " ";
          style = "bold purple";
          format = "[$symbol$branch]($style) ";
        };

        git_status = {
          style = "bold red";
          format = "([$all_status$ahead_behind]($style) )";
        };

        nix_shell = {
          disabled = false;
          impure_msg = "";
          pure_msg = "";
          symbol = "󱄅 ";
          format = "[$symbol]($style)";
          style = "bold blue";
        };

        python = {
          symbol = " ";
          style = "yellow bold";
          format = "via [\${symbol}\${pyenv_prefix}(\${version} )(\(\${virtualenv}\) )](\$style)";
        };

        rust = {
          symbol = " ";
          style = "bold red";
          format = "via [$symbol($version )]($style)";
        };

        nodejs = {
          symbol = " ";
          style = "bold green";
          format = "via [$symbol($version )]($style)";
        };

        docker_context = {
          symbol = " ";
          style = "blue bold";
          format = "via [$symbol$context]($style) ";
        };

        kubernetes = {
          disabled = false;
          symbol = "⎈ ";
          format = "on [$symbol$context( \($namespace\))]($style) ";
        };

        aws = {
          symbol = " ";
          style = "bold yellow";
          format = "on [$symbol($profile )(\($region\) )]($style)";
        };

        time = {
          disabled = false;
          format = "at [$time]($style) ";
          style = "bold white";
          time_format = "%T";
        };

        cmd_duration = {
          min_time = 500;
          format = "took [$duration](bold yellow) ";
        };

        battery = {
          full_symbol = "🔋";
          charging_symbol = "⚡️";
          discharging_symbol = "💀";
          
          display = [
            {
              threshold = 10;
              style = "bold red";
            }
            {
              threshold = 30;
              style = "bold yellow";
            }
          ];
        };
      };
    };
  };
}