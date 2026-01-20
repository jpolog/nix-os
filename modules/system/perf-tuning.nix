{ config, pkgs, lib, ... }:

{
  # System Performance Tuning & Hardware Maintenance
  # (No user packages, only system services and kernel settings)

  # Enable sysstat for performance monitoring service
  services.sysstat.enable = true;
  
  # Enable fwupd for firmware updates
  services.fwupd.enable = true;
  
  # Enable smartd for disk monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };
  
  # Locate database (system-wide service)
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
  };
  
  # Better I/O scheduler for SSDs
  services.udev.extraRules = ''
    # Set scheduler for NVMe
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    # Set scheduler for SSDs and eMMC
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # Set scheduler for rotating disks
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
  
  # Advanced kernel parameters
  boot.kernelParams = [
    "transparent_hugepage=madvise"
    "lockdown=confidentiality"
    "mitigations=auto"
  ];
  
  # Kernel modules
  boot.kernelModules = [
    "tcp_bbr"
    "v4l2loopback"
  ];
  
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';
  
  # Firmware & Microcode
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
}
