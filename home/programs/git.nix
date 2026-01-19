{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    
    settings = {
      user = {
        name = "Javier Polo Gambin";
        email = "javier.polog@outlook.com";
      };
      
      alias = {
        # Short commands
        a = "add";
        aa = "add --all";
        ap = "add --patch";
        
        b = "branch";
        ba = "branch --all";
        bd = "branch --delete";
        bD = "branch --delete --force";
        
        c = "commit";
        ca = "commit --amend";
        cm = "commit --message";
        
        co = "checkout";
        cob = "checkout -b";
        
        d = "diff";
        ds = "diff --staged";
        
        f = "fetch";
        fa = "fetch --all";
        
        l = "log";
        lg = "log --graph --oneline --decorate --all";
        
        p = "push";
        pf = "push --force-with-lease";
        
        pl = "pull";
        
        r = "rebase";
        ri = "rebase --interactive";
        rc = "rebase --continue";
        ra = "rebase --abort";
        
        s = "status --short --branch";
        st = "status";
        
        # Advanced aliases
        amend = "commit --amend --no-edit";
        fixup = "commit --fixup";
        squash = "commit --squash";
        
        # Undo commands
        undo = "reset --soft HEAD^";
        unstage = "reset HEAD --";
        uncommit = "reset --soft HEAD~1";
        
        # Log aliases
        ll = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        
        # Show changed files
        changed = "diff --name-only";
        
        # List aliases
        aliases = "config --get-regexp alias";
        
        # Submodule shortcuts
        subpull = "submodule foreach git pull origin main";
        subupdate = "submodule update --init --recursive";
        
        # Clean shortcuts
        cleanup = "clean -fd";
        prune-branches = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
        
        # Stash shortcuts
        stash-all = "stash save --include-untracked";
        
        # Worktree shortcuts
        wt = "worktree";
        wta = "worktree add";
        wtl = "worktree list";
        wtr = "worktree remove";
        
        # Show current branch
        current = "rev-parse --abbrev-ref HEAD";
        
        # Show root directory
        root = "rev-parse --show-toplevel";
      };
      # Core settings
      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
        pager = "delta";
      };
      
      # Init settings
      init = {
        defaultBranch = "main";
      };
      
      # Pull settings
      pull = {
        rebase = true;
        ff = "only";
      };
      
      # Push settings
      push = {
        default = "current";
        autoSetupRemote = true;
        followTags = true;
      };
      
      # Fetch settings
      fetch = {
        prune = true;
        pruneTags = true;
      };
      
      # Rebase settings
      rebase = {
        autoStash = true;
        autoSquash = true;
      };
      
      # Merge settings
      merge = {
        conflictStyle = "zdiff3";
        tool = "nvimdiff";
      };
      
      # Diff settings
      diff = {
        algorithm = "histogram";
        tool = "nvimdiff";
        colorMoved = "default";
      };
      
      # Interactive settings
      interactive = {
        diffFilter = "delta --color-only";
      };
      
      # Commit settings
      commit = {
        verbose = true;
        # gpgSign = true;  # Enable when GPG key is configured
      };
      
      # Tag settings
      tag = {
        # gpgSign = true;  # Enable when GPG key is configured
        sort = "version:refname";
      };
      
      # Color settings
      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        status = "auto";
      };
      
      # URL rewrites for faster cloning
      url = {
        "https://github.com/".insteadOf = [
          "gh:"
          "github:"
        ];
        "https://gitlab.com/".insteadOf = [
          "gl:"
          "gitlab:"
        ];
      };
      
      # Better status
      status = {
        showUntrackedFiles = "all";
        submoduleSummary = true;
      };
      
      # Submodule settings
      submodule = {
        recurse = true;
      };
      
      # Rerere (reuse recorded resolution)
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      
      # Help settings
      help = {
        autocorrect = 10;  # Auto-correct typos after 1 second
      };
      
      # Branch settings
      branch = {
        sort = "-committerdate";
      };
      
      # Log settings
      log = {
        date = "relative";
      };
      
      # Credential helper
      credential = {
        helper = "cache --timeout=3600";
      };
    };
    
    # Ignore patterns
    ignores = [
      # OS files
      ".DS_Store"
      "Thumbs.db"
      "desktop.ini"
      
      # Editor files
      "*.swp"
      "*.swo"
      "*~"
      ".vscode/"
      ".idea/"
      "*.sublime-*"
      
      # Nix
      "result"
      "result-*"
      ".direnv/"
      
      # Environment
      ".env"
      ".env.local"
      "*.key"
      "*.pem"
      
      # Build artifacts
      "node_modules/"
      "*.pyc"
      "__pycache__/"
      "target/"
      "dist/"
      "build/"
      
      # Logs
      "*.log"
      "npm-debug.log*"
    ];
  };
  
  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      editor = "nvim";
      prompt = "enabled";
      pager = "delta";
    };
  };
  
  # Lazygit TUI
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "#89dceb" "bold" ];
          inactiveBorderColor = [ "#6c7086" ];
          selectedLineBgColor = [ "#313244" ];
        };
        showFileTree = true;
        showRandomTip = false;
        nerdFontsVersion = "3";
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
        commit = {
          signOff = false;
        };
        merging = {
          manualCommit = false;
        };
      };
      update = {
        method = "never";
      };
    };
  };
}
