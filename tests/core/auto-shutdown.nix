{ pkgs, inputs, userState ? {}, ... }:

let
  # Test with auto-shutdown enabled
  testState = userState // {
    core = (userState.core or {}) // {
      auto_shutdown_enabled = true;
      auto_shutdown_idle_minutes = 60;
    };
  };

  testScript = ''
    # Wait for system to boot
    machine.wait_for_unit("default.target")
    
    # Check that auto-shutdown service is running
    machine.wait_for_unit("cafaye-auto-shutdown.service")
    
    # Verify service status
    status = machine.succeed("systemctl is-active cafaye-auto-shutdown")
    assert "active" in status, "Auto-shutdown service should be active"
    
    # Check that the CLI tool is available
    machine.succeed("which caf-auto-shutdown")
    
    # Test CLI status command
    status_output = machine.succeed("caf-auto-shutdown status")
    assert "ENABLED" in status_output, "Status should show enabled"
    
    # Verify the service file exists and has correct configuration
    service_file = machine.succeed("cat /etc/systemd/system/cafaye-auto-shutdown.service")
    assert "ExecStart" in service_file, "Service should have ExecStart directive"
    assert "Restart=always" in service_file, "Service should restart on failure"
    
    # Test disabling the service
    machine.succeed("caf-auto-shutdown disable")
    
    # Verify service is stopped
    status = machine.succeed("systemctl is-active cafaye-auto-shutdown || true")
    assert "inactive" in status or "failed" in status, "Service should be inactive after disable"
    
    # Test re-enabling
    machine.succeed("caf-auto-shutdown enable")
    machine.wait_for_unit("cafaye-auto-shutdown.service")
    
    # Final status check
    final_status = machine.succeed("caf-auto-shutdown status")
    assert "ENABLED" in final_status, "Service should be enabled after re-enabling"
    
    print("All auto-shutdown tests passed!")
  '';
in

pkgs.testers.runNixOSTest {
  name = "core-auto-shutdown";
  
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
  };
  
  testScript = testScript;
}
