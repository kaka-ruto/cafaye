{ pkgs, inputs, userState ? {}, ... }:

let
  # Test state with auto-shutdown enabled
  testState = userState // {
    core = (userState.core or {}) // {
      auto_shutdown_enabled = true;
      auto_shutdown_idle_minutes = 60;
    };
  };

  testScript = ''
    # Wait for system to boot
    machine.wait_for_unit("default.target")
    
    # Test 1: Check that installer scripts exist
    machine.succeed("test -f /root/cafaye/installer/cafaye-execute.sh")
    machine.succeed("test -f /root/cafaye/install.sh")
    machine.succeed("test -x /root/cafaye/installer/cafaye-execute.sh")
    
    # Test 2: Check script syntax
    machine.succeed("bash -n /root/cafaye/installer/cafaye-execute.sh")
    machine.succeed("bash -n /root/cafaye/install.sh")
    
    # Test 3: Check installer has required functions
    machine.succeed("grep -q 'create_installer_script()' /root/cafaye/installer/cafaye-execute.sh")
    machine.succeed("grep -q 'is_in_installer()' /root/cafaye/installer/cafaye-execute.sh")
    machine.succeed("grep -q 'run_in_installer()' /root/cafaye/installer/cafaye-execute.sh")
    machine.succeed("grep -q 'main()' /root/cafaye/installer/cafaye-execute.sh")
    
    # Test 4: Check installer references correct paths
    machine.succeed("grep -q '/root/cafaye' /root/cafaye/installer/cafaye-execute.sh")
    machine.succeed("grep -q 'nixos-install' /root/cafaye/installer/cafaye-execute.sh")
    machine.succeed("grep -q 'nixos-generate-config' /root/cafaye/installer/cafaye-execute.sh")
    
    # Test 5: Check install.sh has non-interactive mode
    machine.succeed("grep -q 'NON_INTERACTIVE' /root/cafaye/install.sh")
    machine.succeed("grep -q '\-\-yes' /root/cafaye/install.sh")
    
    # Test 6: Check error handling
    machine.succeed("grep -q 'set -e' /root/cafaye/installer/cafaye-execute.sh")
    
    # Test 7: Check kexec URL
    machine.succeed("grep -q 'nix-community/nixos-images' /root/cafaye/installer/cafaye-execute.sh")
    
    print("All installer tests passed!")
  '';
in

pkgs.testers.runNixOSTest {
  name = "installer-scripts";
  
  nodes.machine = { config, pkgs, ... }: {
    imports = [
      inputs.self.nixosModules.cafaye
    ];
    
    # Override userState for this test
    _module.args.userState = testState;
    
    # Basic system config
    system.stateVersion = "24.05";
    
    # Minimal boot config for test
    boot.loader.grub.enable = false;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    
    # Ensure installer scripts are available
    environment.etc."cafaye/installer".source = ../../installer;
  };
  
  testScript = testScript;
}
