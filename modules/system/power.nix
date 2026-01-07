{ config, pkgs, ... }:

{
  # Power management for laptops
  services = {
    # TLP for battery optimization
    tlp = {
      enable = true;
      settings = {
        # Battery
        START_CHARGE_THRESH_BAT0 = 20;
        STOP_CHARGE_THRESH_BAT0 = 80;
        
        # CPU
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 50;
        
        # Platform
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
      };
    };
    
    # UPower for battery monitoring
    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 10;
      percentageAction = 5;
      criticalPowerAction = "Hibernate";
    };
    
    # Thermald for thermal management
    thermald.enable = true;
  };

  # Power profiles daemon (alternative to TLP, disabled by default)
  # services.power-profiles-daemon.enable = false;

  # Power management tools
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    tlp
  ];

  # Enable laptop mode
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
}
