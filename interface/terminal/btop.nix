{ config, pkgs, palette, ... }:

{
  # Deployment of the btop theme
  environment.etc."cafaye/btop/themes/catppuccin_mocha.theme".text = ''
    theme[main_bg]="${palette.base}"
    theme[main_fg]="${palette.text}"
    theme[title]="${palette.text}"
    theme[hi_fg]="${palette.blue}"
    theme[selected_bg]="${palette.surface1}"
    theme[selected_fg]="${palette.blue}"
    theme[inactive_fg]="${palette.overlay1}"
    theme[graph_text]="${palette.rosewater}"
    theme[meter_bg]="${palette.surface0}"
    theme[proc_misc]="${palette.rosewater}"
    theme[cpu_box]="${palette.mauve}"
    theme[mem_box]="${palette.green}"
    theme[net_box]="${palette.maroon}"
    theme[processes_box]="${palette.sky}"
    theme[div_line]="${palette.overlay0}"
    theme[temp_start]="${palette.yellow}"
    theme[temp_mid]="${palette.peach}"
    theme[temp_end]="${palette.red}"
    theme[cpu_start]="${palette.blue}"
    theme[cpu_mid]="${palette.sky}"
    theme[cpu_end]="${palette.green}"
    theme[free_start]="${palette.teal}"
    theme[free_mid]="${palette.green}"
    theme[free_end]="${palette.green}"
    theme[cached_start]="${palette.pink}"
    theme[cached_mid]="${palette.mauve}"
    theme[cached_end]="${palette.mauve}"
    theme[available_start]="${palette.rosewater}"
    theme[available_mid]="${palette.flamingo}"
    theme[available_end]="${palette.flamingo}"
    theme[used_start]="${palette.maroon}"
    theme[used_mid]="${palette.red}"
    theme[used_end]="${palette.red}"
    theme[download_start]="${palette.lavender}"
    theme[download_mid]="${palette.blue}"
    theme[download_end]="${palette.blue}"
    theme[upload_start]="${palette.pink}"
    theme[upload_mid]="${palette.mauve}"
    theme[upload_end]="${palette.mauve}"
  '';

  # Deploy basic btop config
  environment.etc."cafaye/btop/btop.conf".text = ''
    color_theme = "/etc/cafaye/btop/themes/catppuccin_mocha.theme"
    theme_background = False
    vim_keys = True
    rounded_corners = True
    graph_symbol = "braille"
    update_ms = 2000
    shown_boxes = "cpu mem net proc"
  '';

  environment.systemPackages = [ pkgs.btop ];
  
  environment.shellAliases = {
    top = "btop --config /etc/cafaye/btop/btop.conf";
  };
}
