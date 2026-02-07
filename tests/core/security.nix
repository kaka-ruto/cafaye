{ pkgs, inputs, userState, ... }:

{
  name = "core-security";
  nodes = {
    machine = {
      imports = [ 
        ../../core/security.nix 
        ../../core/network.nix 
        ../../core/sops.nix
        inputs.sops-nix.nixosModules.sops
      ];
      _module.args = { inherit inputs userState; };
      
      # Mock the sops file presence
      sops.validateSopsFiles = false;
      # Workaround for CI "modules-shrunk" error: force full bootloader + LTS kernel
      virtualisation.useBootLoader = true;
      virtualisation.useEFIBoot = true;
      hardware.enableAllHardware = true;
      boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_6_6;
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    # Check if SSH is enabled
    machine.wait_for_unit("sshd.service")
    # Check if firewall is enabled
    machine.wait_for_unit("firewall.service")
    # Check if fail2ban is running
    machine.wait_for_unit("fail2ban.service")
  '';
}
