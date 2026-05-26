{ prev, final }:

{
  # Upgrade Bun to 1.3.14 to satisfy oh-my-pi requirements
  bun = prev.bun.overrideAttrs (oldAttrs: rec {
    version = "1.3.14";
    src = final.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      sha256 = "13w4gvgwrjq9bi3ddp53hgm3z399d8i2aqpcmsaqbw2mx2pf47lm";
    };
  });

  # Custom scripts and utilities
  # Add your own packages here
  
  # Example: Custom script
  my-custom-tool = prev.writeShellScriptBin "my-tool" ''
    echo "Custom tool"
  '';
}
