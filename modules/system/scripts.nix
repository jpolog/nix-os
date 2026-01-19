{ config, pkgs, lib, ... }:

let
  # Script management system
  scriptctl = pkgs.writeShellScriptBin "scriptctl" (builtins.readFile ../../scripts/scriptctl);
  
  # System scripts
  update-system = pkgs.writeShellScriptBin "update-system" (builtins.readFile ../../scripts/system/update-system);
  cleanup-system = pkgs.writeShellScriptBin "cleanup-system" (builtins.readFile ../../scripts/system/cleanup-system);
  check-system = pkgs.writeShellScriptBin "check-system" (builtins.readFile ../../scripts/system/check-system);
  
  # Development scripts
  dev-env = pkgs.writeShellScriptBin "dev-env" (builtins.readFile ../../scripts/dev/dev-env);
  nix-search = pkgs.writeShellScriptBin "nix-search" (builtins.readFile ../../scripts/dev/nix-search);
  docker-mon = pkgs.writeShellScriptBin "docker-mon" (builtins.readFile ../../scripts/dev/docker-mon);
  nix-repl-advanced = pkgs.writeShellScriptBin "nix-repl-advanced" (builtins.readFile ../../scripts/dev/nix-repl-advanced);
  git-recent = pkgs.writeShellScriptBin "git-recent" (builtins.readFile ../../scripts/dev/git-recent);
  
  # Utility scripts
  quick-backup = pkgs.writeShellScriptBin "quick-backup" (builtins.readFile ../../scripts/util/quick-backup);
  sysmon = pkgs.writeShellScriptBin "sysmon" (builtins.readFile ../../scripts/util/sysmon);
  sys-analyze = pkgs.writeShellScriptBin "sys-analyze" (builtins.readFile ../../scripts/util/sys-analyze);
  perf-profile = pkgs.writeShellScriptBin "perf-profile" (builtins.readFile ../../scripts/util/perf-profile);
  
  # VM management scripts
  vmctl = pkgs.writeShellScriptBin "vmctl" (builtins.readFile ../../scripts/vms/vmctl);
  vm-optimize = pkgs.writeShellScriptBin "vm-optimize" (builtins.readFile ../../scripts/vms/vm-optimize);
  vm-backup = pkgs.writeShellScriptBin "vm-backup" (builtins.readFile ../../scripts/vms/vm-backup);
  
in
{
  # Install all scripts system-wide
  environment.systemPackages = [
    scriptctl
    update-system
    cleanup-system
    check-system
    dev-env
    nix-search
    docker-mon
    nix-repl-advanced
    git-recent
    quick-backup
    sysmon
    sys-analyze
    perf-profile
    vmctl
    vm-optimize
    vm-backup
  ];
  
  # Create scripts directory for all normal users (automatically)
  # This creates .local/bin for each user with a home directory
  systemd.tmpfiles.rules = 
    let
      normalUsers = lib.filterAttrs (name: user: user.isNormalUser) config.users.users;
    in
      lib.mapAttrsToList (name: user: 
        "d ${user.home}/.local/bin 0755 ${name} users -"
      ) normalUsers;
}
