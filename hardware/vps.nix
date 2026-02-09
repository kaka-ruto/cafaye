# VPS Hardware Configuration with Disko
# Defines disk partitioning for DigitalOcean/AWS-style VPSs

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Disk configuration using disko
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # EFI boot partition
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Root partition with ext4
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

  # Boot configuration for VPS
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  # Network configuration - will be overridden by cloud-init or manual config
  networking.useDHCP = lib.mkDefault true;
  
  # Basic system packages for VPS
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    htop
  ];

  # Enable SSH by default
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Firewall - basic setup
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # VPS-specific optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  system.stateVersion = "25.11";
}
