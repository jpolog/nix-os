{ config, pkgs, ... }:

{
  # Walker - Application launcher
  home.packages = with pkgs; [
    walker
  ];

  # Walker configuration
  xdg.configFile."walker/config.json".text = builtins.toJSON {
    placeholder = "Search...";
    fullscreen = false;
    list = {
      height = 400;
    };
    modules = [
      {
        name = "applications";
        prefix = "";
      }
      {
        name = "runner";
        prefix = ">";
      }
      {
        name = "websearch";
        prefix = "?";
      }
      {
        name = "finder";
        prefix = "~";
      }
    ];
    websearch = {
      engines = [
        {
          name = "Google";
          url = "https://www.google.com/search?q=%s";
        }
        {
          name = "DuckDuckGo";
          url = "https://duckduckgo.com/?q=%s";
        }
      ];
    };
  };

  # Walker CSS styling
  xdg.configFile."walker/style.css".text = ''
    * {
      color: #cdd6f4;
      font-family: "JetBrainsMono Nerd Font";
      font-size: 14px;
    }

    #window {
      background: rgba(30, 30, 46, 0.95);
      border-radius: 10px;
      border: 2px solid #89b4fa;
    }

    #input {
      background: rgba(49, 50, 68, 0.8);
      color: #cdd6f4;
      border-radius: 5px;
      padding: 10px;
      margin: 10px;
    }

    #list {
      background: transparent;
      padding: 5px;
    }

    #element {
      background: transparent;
      padding: 8px;
      margin: 2px;
      border-radius: 5px;
    }

    #element:selected {
      background: rgba(137, 180, 250, 0.3);
    }

    #element:hover {
      background: rgba(137, 180, 250, 0.2);
    }
  '';
}
