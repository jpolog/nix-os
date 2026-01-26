{ config, pkgs, lib, ... }:
let
  # --- 1. THE COMPLETE PLUGIN LIST ---
  plugins = with pkgs.vimPlugins; [
    # -- Core LazyVim --
    lazy-nvim
    LazyVim
    bufferline-nvim
    lualine-nvim
    neo-tree-nvim
    nui-nvim
    nvim-web-devicons
    persistence-nvim
    plenary-nvim
    which-key-nvim
    
    # -- UI & Aesthetics --
    dressing-nvim
    flash-nvim
    indent-blankline-nvim
    noice-nvim
    nvim-notify
    tokyonight-nvim
    catppuccin-nvim
    
    # -- Coding & Completion --
    nvim-cmp
    cmp-buffer
    cmp-path
    cmp-nvim-lsp
    cmp_luasnip
    luasnip
    friendly-snippets
    conform-nvim       # Formatting
    nvim-lint          # Linting
    todo-comments-nvim
    trouble-nvim
    
    # -- Editor & Mini Ecosystem --
    gitsigns-nvim
    mini-ai            # Better text objects
    mini-pairs         # Auto pairs
    mini-surround      # Surround actions
    mini-comment       # Commenting
    mini-icons
    telescope-nvim
    telescope-fzf-native-nvim
    
    # -- Treesitter (CRITICAL: Must be in link farm too) --
    nvim-treesitter
    nvim-treesitter-context
    nvim-treesitter-textobjects
    nvim-ts-autotag
    ts-comments-nvim

    # --- LANGUAGE EXTRAS SUPPORT ---
    
    # LSP Config
    nvim-lspconfig
    
    # Rust
    crates-nvim
    rustaceanvim
    
    # JSON/YAML/Schema
    SchemaStore-nvim
    
    # Markdown
    markdown-preview-nvim

    # -- LaTeX --
    vimtex
  ];

  # --- 2. THE LINK FARM GENERATOR ---
  mkEntryFromDrv = drv: {
    name = let
      baseName = lib.getName drv.name;
      # Remove common prefixes and ensure proper naming
      cleanName = lib.removePrefix "lua5.1-" (lib.removePrefix "vimplugin-" baseName);
    in
      cleanName; 
    path = drv;
  };
  
  lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);

in {
  # --- Environment variable ---
  home.sessionVariables = {
    NIX_LAZY_PATH = "${lazyPath}";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # --- 3. RUNTIME BINARIES (Replacing Mason) ---
    extraPackages = with pkgs; [
      # -- System Tools --
      git
      lazygit
      ripgrep
      fd
      curl
      gzip
      gnutar
      
      # -- Clipboard Support (Wayland) --
      wl-clipboard      # Provides wl-copy and wl-paste for system clipboard
      
      # -- Build Tools (for nvim-treesitter health checks) --
      gcc
      tree-sitter
      
      # -- Lua --
      lua-language-server
      stylua
      
      # -- Nix --
      nixd
      nixfmt
      
      # -- Python --
      pyright
      ruff
      
      # -- TypeScript/JS/Web --
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      prettierd
      eslint_d
      tailwindcss-language-server
      
      # -- Rust --
      rust-analyzer
      rustfmt
      
      # -- Go --
      gopls
      gofumpt
      golangci-lint
      
      # -- C/C++ --
      clang-tools
      
      # -- Data/Markup --
      taplo
      yaml-language-server
      marksman
      markdownlint-cli2
      texlab
      shfmt
      shellcheck
    ];

    # --- 4. TREESITTER (keep for parser installation) ---
    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };

  # --- 5. LUA CONFIGURATION ---
  xdg.configFile = {
    # Bootstrap
    "nvim/init.lua".text = ''
      -- Bootstrap lazy.nvim from Nix
      local lazypath = vim.env.NIX_LAZY_PATH .. "/lazy.nvim"
      vim.opt.rtp:prepend(lazypath)
      
      -- System clipboard integration
      vim.opt.clipboard = "unnamedplus"
      
      -- Load LazyVim config
      require("config.lazy")
    '';

    # Lazy Setup & Extras
    "nvim/lua/config/lazy.lua".text = ''
      local lazypath = vim.env.NIX_LAZY_PATH
      
      require("lazy").setup({
        spec = {
          -- Load core LazyVim
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          
          -- Language Extras
          { import = "lazyvim.plugins.extras.lang.typescript" },
          { import = "lazyvim.plugins.extras.lang.json" },
          { import = "lazyvim.plugins.extras.lang.markdown" },
          { import = "lazyvim.plugins.extras.lang.rust" },
          { import = "lazyvim.plugins.extras.lang.go" },
          { import = "lazyvim.plugins.extras.lang.python" },
          
          -- Your custom plugins/overrides
          { import = "plugins" },
        },
        
        defaults = { 
          lazy = false,  -- Load everything by default for stability
          version = false,
        },
        
        -- Tell lazy.nvim to use Nix-provided plugins
        dev = {
          path = lazypath,
          patterns = { "" },  -- Empty string matches ALL plugins
          fallback = true,    -- Allow fallback for snacks.nvim if not in nixpkgs
        },
        
        performance = {
          rtp = { 
            reset = false,  -- Critical: don't reset runtimepath
          },
        },
        
        install = { 
          missing = true,  -- Allow installing snacks.nvim if missing
        },
      })
    '';

    # NixOS-specific overrides
    "nvim/lua/plugins/nix.lua".text = ''
      return {
        -- Disable Mason (we use Nix for binaries)
        { "mason-org/mason.nvim", enabled = false },
        { "mason-org/mason-lspconfig.nvim", enabled = false },

        -- Disable smooth scroll (provided by snacks.nvim in newer LazyVim)
        {
          "folke/snacks.nvim",
          opts = {
            scroll = { enabled = false },
          },
        },

        -- Configure Treesitter to use Nix parsers
        {
          "nvim-treesitter/nvim-treesitter",
          opts = { 
            auto_install = false,
            ensure_installed = {},
          },
          build = false,  -- Disable any build steps
        },
        
        -- Ensure LSPs use system binaries from $PATH
        {
          "neovim/nvim-lspconfig",
          opts = {
            servers = {
              lua_ls = {},
              nixd = {},
              pyright = {},
              rust_analyzer = {},
              gopls = {},
              ts_ls = {},
            },
          },
        },
      }
    '';
  };
}

