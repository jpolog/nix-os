{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Set dotDir to XDG config directory (modern approach)
    dotDir = "${config.xdg.configHome}/zsh";

    history = {
      size = 100000;
      save = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
      expireDuplicatesFirst = true;
    };

    completionInit = ''
      autoload -Uz compinit
      compinit -C
      
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' group-name '
      zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
      zstyle ':completion:*' list-suffixes
      zstyle ':completion:*' expand prefix suffix
      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
      zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
      zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
      zstyle ':completion:*:manuals' separate-sections true
      zstyle ':completion:*:manuals.*' insert-sections true
    '';

    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
      PAGER = "less";
      LESS = "-R";
      PATH = "$HOME/.local/bin:$HOME/.cargo/bin:$PATH";
    };

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      
      # Modern CLI replacements
      ls = "eza --icons --group-directories-first";
      ll = "eza -lah --icons --group-directories-first --git";
      la = "eza -a --icons";
      lt = "eza --tree --icons --level=2";
      llt = "eza -lah --tree --icons --level=2";
      cat = "bat --style=auto";
      grep = "rg";
      find = "fd";
      du = "dust";
      df = "duf";
      top = "btm";
      ps = "procs";
      
      # Git shortcuts
      g = "git";
      gs = "git status --short --branch";
      gst = "git status";
      ga = "git add";
      gaa = "git add --all";
      gap = "git add --patch";
      gc = "git commit";
      gcm = "git commit -m";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpl = "git pull";
      gf = "git fetch";
      gfa = "git fetch --all";
      gco = "git checkout";
      gcb = "git checkout -b";
      gb = "git branch";
      gba = "git branch --all";
      gd = "git diff";
      gds = "git diff --staged";
      glo = "git log --oneline";
      glg = "git log --graph --oneline --decorate --all";
      gll = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      gstash = "git stash";
      gstashp = "git stash pop";
      gwip = "git add -A && git commit -m 'WIP'";
      gunwip = "git reset HEAD~1";
      
      # NixOS management
      nos = "sudo nixos-rebuild switch --flake .#ares";
      nob = "sudo nixos-rebuild boot --flake .#ares";
      not = "sudo nixos-rebuild test --flake .#ares";
      rebuild = "nh os switch";
      rebuild-boot = "nh os boot";
      rebuild-test = "nh os test";
      
      # Nix utilities
      nd = "nix develop";
      ns = "nix shell nixpkgs#";
      nb = "nix build";
      nf = "nix flake";
      nfu = "nix flake update";
      nfc = "nix flake check";
      nfm = "nix flake metadata";
      cleanup = "nh clean all";
      diff-gen = "nvd diff /run/current-system result";
      
      # Docker shortcuts
      d = "docker";
      dc = "docker-compose";
      dcu = "docker-compose up";
      dcud = "docker-compose up -d";
      dcd = "docker-compose down";
      dcl = "docker-compose logs -f";
      dps = "docker ps";
      dpsa = "docker ps -a";
      di = "docker images";
      drm = "docker rm";
      drmi = "docker rmi";
      dex = "docker exec -it";
      dlogs = "docker logs -f";
      
      # Kubernetes shortcuts
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get svc";
      kgd = "kubectl get deployments";
      kl = "kubectl logs -f";
      kex = "kubectl exec -it";
      kdesc = "kubectl describe";
      kapp = "kubectl apply -f";
      kdel = "kubectl delete";
      
      # System shortcuts
      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      h = "history";
      hg = "history | grep";
      ports = "portctl list";
      listening = "ss -tlnp";
      myip = "curl -s ifconfig.me";
      weather = "curl wttr.in";
      
      # Port management
      pf = "portctl find";
      pk = "portctl kill";
      pc = "portctl check";
      prec = "portctl recommend";
      
      # Directory shortcuts
      cdnix = "cd ~/Projects/nix-omarchy/nix";
      cdconfig = "cd ~/.config";
      cdprojects = "cd ~/Projects";
      cddocs = "cd ~/Documents";
      cddl = "cd ~/Downloads";
      
      # Safety aliases
      rm = "trash";
      cp = "cp -i";
      mv = "mv -i";
      
      # Quick edits
      ezshrc = "nvim ~/.zshrc";
      ehypr = "nvim ~/.config/hypr/hyprland.conf";
      ewaybar = "nvim ~/.config/waybar/config";
      
      # Custom scripts
      update = "update-system";
      clean = "cleanup-system";
      check = "check-system";
      backup = "quick-backup";
      monitor = "sysmon";
      scripts = "scriptctl list";
      
      # Development
      serve = "python -m http.server";
      py = "python";
      ipy = "ipython";
    };

    initContent = ''
      if [ -f "$HOME/.nvm/nvm.sh" ]; then
        nvm() {
          unfunction nvm
          source "$HOME/.nvm/nvm.sh"
          nvm "$@"
        }
      fi
      
      eval "$(zoxide init zsh)"
      
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_DEFAULT_OPTS="
        --height 60%
        --layout=reverse
        --border=rounded
        --inline-info
        --preview-window=right:60%:wrap
        --bind='ctrl-/:toggle-preview'
        --bind='ctrl-u:preview-half-page-up'
        --bind='ctrl-d:preview-half-page-down'
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
      
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
      export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
      export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
      
      mkcd() { mkdir -p "$1" && cd "$1"; }
      
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar e "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
      
      fe() {
        local file
        file=$(fd --type f --hidden --follow --exclude .git | fzf --preview 'bat --color=always --line-range :500 {}')
        [ -n "$file" ] && $EDITOR "$file"
      }
      
      fcd() {
        local dir
        dir=$(fd --type d --hidden --follow --exclude .git | fzf --preview 'eza --tree --color=always {} | head -200')
        [ -n "$dir" ] && cd "$dir"
      }
      
      fgl() {
        git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
        fzf --ansi --no-sort --reverse --tiebreak=index \
            --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show --color=always %' \
            --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % git show %"
      }
      
      fkill() {
        local pid
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        [ -n "$pid" ] && kill -''${1:-9} $pid
      }
      
      dsh() {
        local cid
        cid=$(docker ps | sed 1d | fzf -1 -q "$1" | awk '{print $1}')
        [ -n "$cid" ] && docker exec -it "$cid" /bin/bash
      }
      
      note() {
        local note_file="$HOME/Documents/notes/$(date +%Y-%m-%d).md"
        mkdir -p "$(dirname "$note_file")"
        if [ $# -eq 0 ]; then
          $EDITOR "$note_file"
        else
          echo "$(date +%Y-%m-%d\ %H:%M:%S) - $*" >> "$note_file"
        fi
      }
      
      gwt-add() {
        git worktree add "../$(basename $(pwd))-$1" "$1"
      }
      
      bindkey -v
      export KEYTIMEOUT=1
      
      function zle-keymap-select {
        if [[ ''${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
          echo -ne '\e[1 q'
	elif [[ ''${KEYMAP} == main ]] || [[ ''${KEYMAP} == viins ]] || [[ -z ''${KEYMAP} ]] || [[ $1 = 'beam' ]]; then

          echo -ne '\e[5 q'
        fi
      }
      zle -N zle-keymap-select
      
      echo -ne '\e[5 q'
      
      bindkey '^R' history-incremental-search-backward
      bindkey '^S' history-incremental-search-forward
      bindkey '^P' up-line-or-search
      bindkey '^N' down-line-or-search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
      bindkey '^[[3~' delete-char
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      
      if command -v fastfetch >/dev/null 2>&1; then
        fastfetch --config none --structure Title:Separator:OS:Host:Kernel:Uptime:Packages:Shell:Terminal
      elif command -v neofetch >/dev/null 2>&1; then
        neofetch --config none
      fi
      
      if [ -n "''${IN_NIX_SHELL:-}" ]; then
        echo "🐚 In nix-shell"
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "sudo" 
        "docker" 
        "docker-compose"
        "kubectl" 
        "terraform"
        "rust"
        "golang"
        "python"
        "node"
        "npm"
        "systemd"
        "ssh-agent"
        "gpg-agent"
        "colored-man-pages"
        "command-not-found"
        "history-substring-search"
      ];
    };
  };
}
