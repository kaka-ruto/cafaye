{ config, pkgs, userState, ... }:

{
  # Kernel tweaks for security hardening
  boot.kernel.sysctl = {
    # Security: Kernel pointer protection
    "kernel.kptr_restrict" = 2;
    # ASLR enforcement
    "kernel.randomize_va_space" = 2;
  };
}
