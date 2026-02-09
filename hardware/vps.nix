# VPS Hardware Configuration with Disko
# Defines disk partitioning for DigitalOcean/AWS-style VPSs

{ config, lib, pkgs, modulesPath, userState, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Disk configuration using disko
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault (userState.core.boot.grub_device or "/dev/sda");
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

  # Note: boot.loader.grub is configured in core/boot.nix
  # Network configuration - will be overridden by cloud-init or manual config
  networking.useDHCP = lib.mkDefault true;
  
  # Basic system packages for VPS
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    htop
  ];

  # Note: SSH and firewall are configured in core/security.nix

  # VPS-specific optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };
}
