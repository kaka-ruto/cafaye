{ config, pkgs, palette, ... }:

let
  aboutFile = "/etc/cafaye/branding/about.txt";
  # We'll use a simplified version of the Omarchy fastfetch config
  fastfetchConfig = {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
    logo = {
      type = "file";
      source = aboutFile;
      color = { "1" = "blue"; };
      padding = {
        top = 2;
        right = 6;
        left = 2;
      };
    };
    modules = [
      "break"
      {
        type = "custom";
        format = "\u001b[90m┌──────────────────────Hardware──────────────────────┐";
      }
      {
        type = "host";
        key = " VPS";
        keyColor = "blue";
      }
      {
        type = "cpu";
        key = "│ ├";
        keyColor = "blue";
      }
      {
        type = "disk";
        key = "│ ├󰋊";
        keyColor = "blue";
      }
      {
        type = "memory";
        key = "│ ├";
        keyColor = "blue";
      }
      {
        type = "swap";
        key = "└ └󰓡 ";
        keyColor = "blue";
      }
      {
        type = "custom";
        format = "\u001b[90m└────────────────────────────────────────────────────┘";
      }
      "break"
      {
        type = "custom";
        format = "\u001b[90m┌──────────────────────Software──────────────────────┐";
      }
      {
        type = "os";
        key = "󱄅 OS";
        keyColor = "mauve";
      }
      {
        type = "kernel";
        key = "│ ├";
        keyColor = "mauve";
      }
      {
        type = "shell";
        key = "│ ├";
        keyColor = "mauve";
      }
      {
        type = "packages";
        key = "│ ├󰏖";
        keyColor = "mauve";
      }
      {
        type = "uptime";
        key = "└ └󱫐 ";
        keyColor = "mauve";
      }
      {
        type = "custom";
        format = "\u001b[90m└────────────────────────────────────────────────────┘";
      }
      "break"
    ];
  };
in
{
  # Deploy config file
  environment.etc."cafaye/fastfetch/config.jsonc".text = builtins.toJSON fastfetchConfig;

  # Create an alias for easy execution
  environment.shellAliases = {
    fetch = "fastfetch --config /etc/cafaye/fastfetch/config.jsonc";
  };
}
