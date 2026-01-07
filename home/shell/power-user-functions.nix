{ config, pkgs, lib, ... }:

{
  # Advanced ZSH plugins and configurations for power users
  
  programs.zsh = {
    # Advanced plugins
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "sha256-Z6EYQdasvpl1P78poj9efnnLj7QQg13Me8x1Ryyw+dM=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          sha256 = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
        };
      }
      {
        name = "zsh-autocomplete";
        file = "zsh-autocomplete.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "marlonrichert";
          repo = "zsh-autocomplete";
          rev = "24.09.04";
          sha256 = "sha256-M9vZ91FkdwIVvzAIiVvPGA7XEPvIKeTCRoXpJGBxCvs=";
        };
      }
      {
        name = "zsh-you-should-use";
        file = "you-should-use.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          sha256 = "sha256-6Bqc/P5fiIfwMMLPFwZFU+y6nQBuGwC3CkzBDUwv5LI=";
        };
      }
    ];
  };
  
  # Power user shell functions
  programs.zsh.initExtra = lib.mkAfter ''
    # Advanced directory navigation
    # z.lua for smart directory jumping
    eval "$(${pkgs.z-lua}/bin/z.lua --init zsh enhanced once fzf)"
    
    # Bookmark directories
    hash -d nix=~/Projects/nix-omarchy/nix
    hash -d proj=~/Projects
    hash -d dots=~/.config
    hash -d dl=~/Downloads
    
    # Quick directory stack navigation
    setopt AUTO_PUSHD
    setopt PUSHD_IGNORE_DUPS
    setopt PUSHD_SILENT
    alias d='dirs -v'
    for index ({1..9}) alias "$index"="cd +''${index}"; unset index
    
    # Smart cd that lists contents
    cd() {
      builtin cd "$@" && ls --color=auto -F
    }
    
    # Quick find and execute
    qfind() {
      find . -name "*$1*" -type f -exec ${pkgs.bat}/bin/bat {} \;
    }
    
    # Repeat last command with sudo
    please() {
      sudo $(fc -ln -1)
    }
    
    # Create directory and cd into it
    mkcd() {
      mkdir -p "$1" && cd "$1"
    }
    
    # Extract any archive
    x() {
      if [ -f "$1" ]; then
        case "$1" in
          *.tar.bz2)   tar xjf "$1"     ;;
          *.tar.gz)    tar xzf "$1"     ;;
          *.tar.xz)    tar xJf "$1"     ;;
          *.bz2)       bunzip2 "$1"     ;;
          *.rar)       unrar x "$1"     ;;
          *.gz)        gunzip "$1"      ;;
          *.tar)       tar xf "$1"      ;;
          *.tbz2)      tar xjf "$1"     ;;
          *.tgz)       tar xzf "$1"     ;;
          *.zip)       unzip "$1"       ;;
          *.Z)         uncompress "$1"  ;;
          *.7z)        7z x "$1"        ;;
          *)           echo "'$1' cannot be extracted via x()" ;;
        esac
      else
        echo "'$1' is not a valid file"
      fi
    }
    
    # Quick HTTP server
    serve() {
      local port="''${1:-8000}"
      ${pkgs.python3}/bin/python -m http.server "$port"
    }
    
    # Weather
    wttr() {
      curl "wttr.in/''${1:-Madrid}?format=3"
    }
    
    # Cheat sheets
    cheat() {
      curl "cheat.sh/$1"
    }
    
    # Convert between formats
    convert-to-mp3() {
      ${pkgs.ffmpeg}/bin/ffmpeg -i "$1" -acodec libmp3lame -ab 320k "''${1%.*}.mp3"
    }
    
    # Optimize images
    optimg() {
      for img in "$@"; do
        case "$img" in
          *.png) ${pkgs.oxipng}/bin/oxipng -o 6 "$img" ;;
          *.jpg|*.jpeg) ${pkgs.jpegoptim}/bin/jpegoptim --max=85 "$img" ;;
        esac
      done
    }
    
    # Quick backup with timestamp
    bak() {
      cp "$1" "$1.bak-$(date +%Y%m%d-%H%M%S)"
    }
    
    # Monitor command output
    watch-cmd() {
      watch -c -n 1 "$@"
    }
    
    # JSON pretty print
    json() {
      if [ -t 0 ]; then
        ${pkgs.jq}/bin/jq '.' "$@"
      else
        ${pkgs.jq}/bin/jq '.'
      fi
    }
    
    # Process tree
    pstree() {
      ${pkgs.procs}/bin/procs --tree
    }
    
    # Memory usage by process
    memtop() {
      ps aux | sort -nk 4 | tail -20
    }
    
    # CPU usage by process
    cputop() {
      ps aux | sort -nk 3 | tail -20
    }
    
    # Network connections
    netstat-listen() {
      ss -tulpn
    }
    
    # Find process by port
    port() {
      lsof -i :"$1"
    }
    
    # Disk usage of directories
    duh() {
      du -h --max-depth=1 | sort -h
    }
    
    # Count files in directory
    count() {
      find "''${1:-.}" -type f | wc -l
    }
    
    # Generate random password
    genpass() {
      < /dev/urandom tr -dc 'A-Za-z0-9!@#$%^&*' | head -c''${1:-32}
      echo
    }
    
    # Git shortcuts
    gclone() {
      git clone "$1" && cd "$(basename "$1" .git)"
    }
    
    # Nix shortcuts
    nix-shell-pure() {
      nix-shell --pure "$@"
    }
    
    # Quick note taking
    n() {
      $EDITOR ~/Documents/notes/"$(date +%Y-%m-%d)".md
    }
    
    # Quick todo
    todo() {
      if [ $# -eq 0 ]; then
        ${pkgs.bat}/bin/bat ~/Documents/todo.md
      else
        echo "- [ ] $*" >> ~/Documents/todo.md
      fi
    }
    
    # System info quick
    sysinfo() {
      echo "CPU: $(nproc) cores"
      echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
      echo "Disk: $(df -h / | awk 'NR==2 {print $4 " free"}')"
      echo "Uptime: $(uptime -p)"
    }
    
    # Docker cleanup
    docker-clean() {
      docker system prune -af --volumes
    }
    
    # Kubernetes context switching
    kctx() {
      kubectl config use-context "$1"
    }
    
    # SSH with agent forwarding
    ssha() {
      ssh -A "$@"
    }
    
    # Rsync with progress
    rcp() {
      rsync -avhP "$@"
    }
    
    # Find large files
    largest() {
      du -ah "''${1:-.}" | sort -rh | head -20
    }
    
    # Calculator
    calc() {
      echo "$*" | bc -l
    }
    
    # Colored man pages
    man() {
      LESS_TERMCAP_md=$'\e[01;31m' \
      LESS_TERMCAP_me=$'\e[0m' \
      LESS_TERMCAP_se=$'\e[0m' \
      LESS_TERMCAP_so=$'\e[01;44;33m' \
      LESS_TERMCAP_ue=$'\e[0m' \
      LESS_TERMCAP_us=$'\e[01;32m' \
      command man "$@"
    }
    
    # FZF enhanced history
    fh() {
      print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
    }
    
    # FZF enhanced kill
    fk() {
      local pid
      if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
      else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
      fi
      if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -''${1:-9}
      fi
    }
    
    # Git worktree with fzf
    gwt() {
      local branch
      branch=$(git branch --all | grep -v HEAD | fzf | sed 's/^[* ]*//' | sed 's#remotes/origin/##')
      if [ -n "$branch" ]; then
        git worktree add "../$(basename $(pwd))-$branch" "$branch"
      fi
    }
    
    # Tmux session switcher
    ts() {
      local session
      session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --query="$1" --select-1 --exit-0)
      if [ -n "$session" ]; then
        tmux switch-client -t "$session" || tmux attach -t "$session"
      fi
    }
    
    # Quick benchmark
    bench() {
      hyperfine "$@"
    }
    
    # System stats
    stats() {
      echo "=== System Statistics ==="
      echo ""
      echo "CPU Usage:"
      mpstat 1 1
      echo ""
      echo "Memory:"
      free -h
      echo ""
      echo "Disk I/O:"
      iostat -x 1 2
      echo ""
      echo "Network:"
      ip -s link
    }
  '';
}
