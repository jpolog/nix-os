{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.cli.enable {
    programs.git = {
      enable = true;
      
      settings = {
        user = {
          name = lib.mkDefault "Your Name";
          email = lib.mkDefault "your.email@example.com";
        };
        
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          lg = "log --graph --oneline --decorate --all";
        };
        
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "nvim";
        safe.directory = "/etc/nixos";
      };
    };
    
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
      };
    };
  };
}
