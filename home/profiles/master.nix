{ config, lib, pkgs, ... }:

with lib;

let
  # Use Python 3.12 with a package set override.
  orangePython = pkgs.python312.override {
    packageOverrides = self: super: {
      pyqt5 = self.pyqt6;
      pyqtwebengine = self.pyqt6-webengine;
      catboost = null;

      orange-canvas-core = super.orange-canvas-core.overridePythonAttrs (old: {
        propagatedBuildInputs = builtins.filter (p: p != null) (old.propagatedBuildInputs or []);
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
          self.trubar 
          self.pythonRelaxDepsHook
          self.myst-parser
          self.sphinx
        ];
        pythonRemoveDeps = (old.pythonRemoveDeps or []) ++ [ 
          "sphinx-multiproject" 
          "myst-parser" 
          "sphinx"
        ];
        postPatch = (old.postPatch or "") + ''
          if [ -f pyproject.toml ]; then
            substituteInPlace pyproject.toml \
              --replace-fail '"sphinx-multiproject",' "" \
              --replace-fail '"myst-parser",' "" \
              --replace-fail '"sphinx>=4.2.0,<8",' "" || true
          fi
        '';
        doCheck = false;
      });

      orange-widget-base = super.orange-widget-base.overridePythonAttrs (old: {
        propagatedBuildInputs = builtins.filter (p: p != null) (old.propagatedBuildInputs or []);
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
          self.trubar 
          self.pythonRelaxDepsHook
          self.myst-parser
          self.sphinx
        ];
        pythonRemoveDeps = (old.pythonRemoveDeps or []) ++ [ 
          "sphinx-multiproject" 
          "myst-parser" 
          "sphinx"
        ];
        postPatch = (old.postPatch or "") + ''
          if [ -f pyproject.toml ]; then
            substituteInPlace pyproject.toml \
              --replace-fail '"sphinx-multiproject",' "" \
              --replace-fail '"myst-parser",' "" \
              --replace-fail '"sphinx>=4.2.0,<8",' "" || true
          fi
        '';
        doCheck = false;
      });

      orange3 = super.orange3.overridePythonAttrs (old: {
        propagatedBuildInputs = builtins.filter (p: p != null) (old.propagatedBuildInputs or []);
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
          self.trubar 
          self.pythonRelaxDepsHook
          self.myst-parser
          self.sphinx
        ];
        pythonRemoveDeps = (old.pythonRemoveDeps or []) ++ [ 
          "sphinx-multiproject" 
          "myst-parser" 
          "sphinx"
        ];
        postPatch = (old.postPatch or "") + ''
          substituteInPlace pyproject.toml \
            --replace-fail '"sphinx-multiproject",' "" \
            --replace-fail '"myst-parser",' "" \
            --replace-fail '"sphinx>=4.2.0,<8",' ""
        '';
        doCheck = false;
      });
    };
  };

  orangePackages = orangePython.pkgs;

  orange3-educational = orangePackages.buildPythonPackage rec {
    pname = "Orange3-Educational";
    version = "0.8.1";
    format = "setuptools";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/ac/80/33d079db30d1a1e65f526083729bc11a8702d1b07fb58f7ad6e5ed6e6e78/orange3_educational-0.8.1.tar.gz";
      sha256 = "41b40ccc18f84217ede98e95d7044bcb6cd274010b2fa18d9a432ceaa6c295c0";
    };
    doCheck = false; 
    propagatedBuildInputs = [ 
      orangePackages.orange3
      orangePackages.numpy
      orangePackages.scipy
    ];
    meta = with lib; {
      description = "Orange Data Mining Educational add-on";
      homepage = "https://github.com/biolab/orange3-educational";
      license = licenses.gpl3;
    };
  };

  orange3-explain = orangePackages.buildPythonPackage rec {
    pname = "Orange3-Explain";
    version = "0.6.11";
    format = "setuptools";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/80/db/1133d1f8e4473f6b5eb5a9a7ed016850b0dcc28422bc7b36e0ca8ffc4c3f/orange3_explain-0.6.11.tar.gz";
      sha256 = "bae4eeca55b41e95b19fd73df2d76fae28a1b14598c06a0b6c4a83ff72d96ebf";
    };
    doCheck = false; 
    propagatedBuildInputs = [ 
      orangePackages.orange3
      orangePackages.numpy
      orangePackages.scipy
      orangePackages.shap
      orangePackages.anyqt
      orangePackages.pyqtgraph
      orangePackages.pandas
    ];
    meta = with lib; {
      description = "Orange Data Mining Explain add-on";
      homepage = "https://github.com/biolab/orange3-explain";
      license = licenses.gpl3;
    };
  };

  # Create the isolated Orange environment
  orangeEnv = orangePython.withPackages (ps: with ps; [
    orange3
    orange3-educational
    orange3-explain
    numpy
    scipy
    shap
    pandas
  ]);

  # Create a dedicated launcher that exposes ONLY orange-canvas
  # This prevents file conflicts (like .f2py-wrapped) with the main Python environment
  orangeLauncher = pkgs.writeShellScriptBin "orange-canvas" ''
    exec ${orangeEnv}/bin/orange-canvas "$@"
  '';

in

{
  options.home.profiles.master = {
    enable = mkEnableOption "AI Master's degree profile";
  };

  config = mkIf config.home.profiles.master.enable {
    home.packages = [
      # Standard Data Science Stack (Python 3.13 / Unstable)
      (pkgs.python3.withPackages (ps: with ps; [
        numpy
        pandas
        scikit-learn
        matplotlib
        seaborn
        jupyter
        notebook
        ipython
        scipy
        torch
        xgboost
      ]))

      # Orange Data Mining (Isolated Launcher)
      orangeLauncher
    ];
  };
}
