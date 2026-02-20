{ config, pkgs, lib, ... }:
let
  # --- CUSTOM PLUGINS ---
  pathfinder-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "pathfinder-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "HawkinsT";
      repo = "pathfinder.nvim";
      rev = "9c79815dfd31726119b44a71c0654377be01d3c2";
      sha256 = "1i64rkcd534ri2mcb5nv070byljxwa30n97p7nrlliwqrnmw49xw";
    };
  };

  # --- 1. THE COMPLETE PLUGIN LIST ---
  plugins = with pkgs.vimPlugins; [
    # -- Core LazyVim --
    lazy-nvim
    LazyVim
    bufferline-nvim
    lualine-nvim
    # neo-tree-nvim -- DISABLED
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
    mini-comment       # Kept as requested
    mini-icons
    telescope-nvim
    telescope-fzf-native-nvim
    
    # -- Treesitter --
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

    # -- Notebooks & Data Science --
    image-nvim

    # --- NEW USER REQUESTED PLUGINS ---
    harpoon2
    sniprun
    obsidian-nvim
    pathfinder-nvim
    
    # -- Snacks (Required for the explorer) --
    snacks-nvim
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

  # --- Ranger Alias ---
  home.shellAliases = {
    rr = "ranger";
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
      imagemagick  # For image rendering in Neovim (image.nvim/molten-nvim)
      
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

    # --- 5. LUA PACKAGES ---
    extraLuaPackages = ps: [
      ps.magick # For image.nvim
    ];

    # --- 6. CONFIGURATION ---
    extraLuaConfig = ''
      -- Disable netrw to avoid double explorer issue
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Bootstrap lazy.nvim from Nix
      local lazypath = vim.env.NIX_LAZY_PATH .. "/lazy.nvim"
      vim.opt.rtp:prepend(lazypath)
      
      -- System clipboard integration
      vim.opt.clipboard = "unnamedplus"
      
      -- Load LazyVim config
      require("config.lazy")
    '';
  };

  # --- 7. Ranger Configuration ---
  programs.ranger = {
    enable = true;
    extraConfig = ''
      set preview_images true
      set preview_images_method kitty
      set draw_borders both
      set unicode_ellipsis true
    '';
    # Tools for better previews in Ranger
    extraPackages = with pkgs; [
      poppler-utils # PDF previews
      ffmpegthumbnailer # Video previews
      imagemagick # Image manipulation for previews
      highlight # Syntax highlighting for code previews
      atool # Archive previews
      libcaca # ASCII art previews (fallback)
      w3m # Fallback image support
      font-awesome # Icons if supported
    ];
  };

  # --- 8. OTHER LUA FILES ---
  xdg.configFile = {
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

        rocks = {
          enabled = false,
        },
      })
    '';

    # Configure Snacks Explorer: Toggled preview with P
    "nvim/lua/plugins/snacks.lua".text = ''
      return {
        {
          "folke/snacks.nvim",
          priority = 1000,
          lazy = false,
          opts = {
            explorer = {
              enabled = true,
              replace_netrw = true,
            },
            picker = {
              sources = {
                explorer = {
                  auto_preview = false, -- Disabled by default
                  layout = {
                    preset = "sidebar",
                    preview = "bottom",
                  },
                  win = {
                    list = {
                      keys = {
                        -- Toggle preview with P (it defaults to bottom per layout)
                        ["P"] = "preview",
                      },
                    },
                  },
                },
              },
            },
          },
        },
      }
    '';
    
    # Disable Conflicting Explorers
    "nvim/lua/plugins/disabled.lua".text = ''
      return {
        -- Disable Neo-tree
        { "nvim-neo-tree/neo-tree.nvim", enabled = false },
        -- Disable Oil
        { "stevearc/oil.nvim", enabled = false },
        -- Disable mini.files
        { "echasnovski/mini.files", enabled = false },
      }
    '';

    # Image.nvim Configuration
    "nvim/lua/plugins/image.lua".text = ''
      return {
        {
          "3rd/image.nvim",
          opts = {
            backend = "kitty", 
            integrations = {
              markdown = {
                enabled = true,
                clear_in_insert_mode = false,
                download_remote_images = true,
                only_render_image_at_cursor = false,
                filetypes = { "markdown", "vimwiki" }, 
              },
              neorg = {
                enabled = true,
                clear_in_insert_mode = false,
                download_remote_images = true,
                only_render_image_at_cursor = false,
                filetypes = { "norg" },
              },
            },
            max_width = nil,
            max_height = nil,
            max_width_window_percentage = nil,
            max_height_window_percentage = 50,
            window_overlap_clear_enabled = false, 
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
            editor_only_render_when_focused = false, 
            tmux_show_only_in_active_window = true, 
            hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, 
          },
        },
      }
    '';

    # Harpoon Configuration
    "nvim/lua/plugins/harpoon.lua".text = ''
      return {
        {
          "ThePrimeagen/harpoon",
          branch = "harpoon2",
          dependencies = { "nvim-lua/plenary.nvim" },
          config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
          end,
        }
      }
    '';

    # Sniprun Configuration
    "nvim/lua/plugins/sniprun.lua".text = ''
      return {
        {
          "michaelb/sniprun",
          branch = "master",
          build = "sh ./install.sh",
          config = function()
            require("sniprun").setup({
              display = {
                "Terminal",
                "VirtualTextOk",
              },
            })
          end,
        }
      }
    '';

    # Obsidian Configuration
    "nvim/lua/plugins/obsidian.lua".text = ''
      return {
        {
          "epwalsh/obsidian.nvim",
          version = "*", 
          lazy = true,
          ft = "markdown",
          dependencies = { "nvim-lua/plenary.nvim" },
          opts = {
            workspaces = {
              {
                name = "personal",
                path = "~/obsidian",
              },
            },
          },
        }
      }
    '';

    # Pathfinder Configuration
    "nvim/lua/plugins/pathfinder.lua".text = ''
      return {
        {
          "HawkinsT/pathfinder.nvim",
          opts = {},
        }
      }
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

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "kitty nvim %U";
    terminal = false;
    type = "Application";
    categories = [ "Utility" "TextEditor" ];
    mimeType = [ "text/plain" ];
  };
}