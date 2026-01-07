{ config, lib, pkgs, ... }:

with lib;

{
  options.profiles.power-user = {
    enable = mkEnableOption "power user packages and tools";
    
    scientific = {
      enable = mkEnableOption "scientific computing tools";
      octave.enable = mkEnableOption "GNU Octave (MATLAB alternative)";
      jupyter.enable = mkEnableOption "Jupyter notebooks";
    };
    
    creative = {
      enable = mkEnableOption "creative tools (GIMP, Inkscape, etc.)";
      video.enable = mkEnableOption "video editing tools";
      modeling3d.enable = mkEnableOption "3D modeling tools";
    };
  };

  config = mkMerge [
    # Base power user tools (always enabled if profile is)
    (mkIf config.profiles.power-user.enable {
      environment.systemPackages = with pkgs; [
        # Terminal tools
        ranger
        yazi
        fzf
        ripgrep
        fd
        eza
        bat
        delta
        zoxide
        
        # System monitoring
        btop
        nvtop
        bandwhich
        
        # Network tools
        nmap
        mtr
        wireshark
        
        # Development
        lazygit
        tig
        gh
      ];
    })

    # Scientific computing
    (mkIf config.profiles.power-user.scientific.enable {
      environment.systemPackages = with pkgs;
        (optionals config.profiles.power-user.scientific.octave.enable [
          octave
        ])
        ++
        (optionals config.profiles.power-user.scientific.jupyter.enable [
          jupyter
        ]);
    })

    # Creative tools
    (mkIf config.profiles.power-user.creative.enable {
      environment.systemPackages = with pkgs; [
        gimp
        inkscape
        krita
      ]
      ++
      (optionals config.profiles.power-user.creative.video.enable [
        kdenlive
        obs-studio
      ])
      ++
      (optionals config.profiles.power-user.creative.modeling3d.enable [
        blender
      ]);
    })
  ];
}
