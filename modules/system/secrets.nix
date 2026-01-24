{ config, pkgs, lib, ... }:

{
  # SOPS (Secrets OPerationS) for managing encrypted secrets in git
  # 
  # Setup instructions:
  # 1. Generate an age key:
  #    $ mkdir -p ~/.config/sops/age
  #    $ age-keygen -o ~/.config/sops/age/keys.txt
  #
  # 2. Create .sops.yaml in repository root:
  #    keys:
  #      - &admin_jpolo YOUR_PUBLIC_AGE_KEY_HERE
  #    creation_rules:
  #      - path_regex: secrets/.*\.yaml$
  #        key_groups:
  #          - age:
  #            - *admin_jpolo
  #
  # 3. Create a secret file:
  #    $ sops secrets/example.yaml
  #
  # 4. Reference secrets in NixOS config:
  #    sops.secrets."example/password" = {
  #      sopsFile = ./secrets/example.yaml;
  #    };
  
  # SOPS configuration
  sops = {
    # Default sops file location
    defaultSopsFile = ../../secrets/secrets.yaml;
    
    # Validate sops files on build
    validateSopsFiles = true; 
    
    # Age key file location
    age = {
      # Key file for decryption
      keyFile = "/home/jpolo/.config/sops/age/keys.txt";
      
      # Generate key file if it doesn't exist
      generateKey = true; # You generated it manually
      
      # SSH host key can be used instead
      # sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
    
    # Secrets configuration
    secrets = {
      ssh_key = {
        owner = "jpolo";
        path = "/home/jpolo/.ssh/id_ed25519"; 
        mode = "0600";
      };
    };
  };
  
  # Install sops for manual secret management
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age  # Convert SSH keys to age keys
  ];
  
  # Example home-manager secrets integration
  # home-manager.users.jpolo = {
  #   home.file.".ssh/id_ed25519" = {
  #     source = config.sops.secrets."ssh/private-key".path;
  #   };
  # };
}
