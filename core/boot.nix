{ config, pkgs, userState, ... }:

{
  # Bootloader configuration
  boot.loader.grub = {
    enable = true;
    device = userState.core.boot.grub_device or "/dev/vda";
  };

  # Use a modern kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ZRAM for efficient memory usage on low-RAM VPS
  zramSwap.enable = userState.core.zram_enabled or true;
  zramSwap.memoryPercent = 50;

  # Kernel tweaks for performance and security
  boot.kernel.sysctl = {
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;
  };
}
