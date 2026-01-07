{ config, lib, pkgs, ... }:

with lib;

{
  options.profiles.development = {
    enable = mkEnableOption "development environment profile";
    
    languages = {
      python.enable = mkEnableOption "Python development tools" // { default = true; };
      nodejs.enable = mkEnableOption "Node.js development tools" // { default = true; };
      rust.enable = mkEnableOption "Rust development tools";
      go.enable = mkEnableOption "Go development tools";
      cpp.enable = mkEnableOption "C/C++ development tools";
      java.enable = mkEnableOption "Java development tools";
      zig.enable = mkEnableOption "Zig development tools";
    };
    
    tools = {
      docker.enable = mkEnableOption "Docker and container tools" // { default = true; };
      cloud.enable = mkEnableOption "Cloud CLI tools (AWS, GCP, Azure)";
      kubernetes.enable = mkEnableOption "Kubernetes tools";
      databases.enable = mkEnableOption "Database tools";
      api.enable = mkEnableOption "API testing tools";
    };
  };

  config = mkIf config.profiles.development.enable {
    imports = [
      ../development/direnv.nix
      ../development/tools.nix
    ];

    # Docker
    virtualisation.docker.enable = mkIf config.profiles.development.tools.docker.enable true;
    users.users.jpolo.extraGroups = mkIf config.profiles.development.tools.docker.enable [ "docker" ];

    environment.systemPackages = with pkgs;
      # Python
      (optionals config.profiles.development.languages.python.enable [
        python312
        python312Packages.pip
        python312Packages.virtualenv
        pyright
        black
      ])
      ++
      # Node.js
      (optionals config.profiles.development.languages.nodejs.enable [
        nodejs_22
        nodePackages.npm
        nodePackages.yarn
        nodePackages.pnpm
        nodePackages.typescript-language-server
        prettier
      ])
      ++
      # Rust
      (optionals config.profiles.development.languages.rust.enable [
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
      ])
      ++
      # Go
      (optionals config.profiles.development.languages.go.enable [
        go
        gotools
        gopls
      ])
      ++
      # C/C++
      (optionals config.profiles.development.languages.cpp.enable [
        gcc
        clang
        cmake
        gnumake
      ])
      ++
      # Java
      (optionals config.profiles.development.languages.java.enable [
        jdk21
      ])
      ++
      # Zig
      (optionals config.profiles.development.languages.zig.enable [
        zig
      ])
      ++
      # Cloud tools
      (optionals config.profiles.development.tools.cloud.enable [
        awscli2
        google-cloud-sdk
        azure-cli
        terraform
        terragrunt
        ansible
      ])
      ++
      # Kubernetes
      (optionals config.profiles.development.tools.kubernetes.enable [
        kubectl
        k9s
        helm
        kind
      ])
      ++
      # Databases
      (optionals config.profiles.development.tools.databases.enable [
        sqlite
        postgresql
        redis
        dbeaver-bin
      ])
      ++
      # API testing
      (optionals config.profiles.development.tools.api.enable [
        postman
        insomnia
        httpie
      ]);
  };
}
