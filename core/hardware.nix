{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Basic storage configuration (standard for cloud-init/nixos-anywhere deployments)
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  # Make KVM modules optional to avoid failure on systems without VT-x/AMD-V
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Note: fileSystems are defined by disko in hardware/vps.nix
  # This is intentionally left empty to avoid conflicts

  swapDevices = [ ];
}
