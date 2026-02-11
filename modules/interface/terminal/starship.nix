{ config, pkgs, palette, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 200;
      format = "[$directory$git_branch$git_status]($style)$character";
      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "${palette.rosewater}";
        flamingo = "${palette.flamingo}";
        pink = "${palette.pink}";
        mauve = "${palette.mauve}";
        red = "${palette.red}";
        maroon = "${palette.maroon}";
        peach = "${palette.peach}";
        yellow = "${palette.yellow}";
        green = "${palette.green}";
        teal = "${palette.teal}";
        sky = "${palette.sky}";
        sapphire = "${palette.sapphire}";
        blue = "${palette.blue}";
        lavender = "${palette.lavender}";
        text = "${palette.text}";
        subtext1 = "${palette.subtext1}";
        subtext0 = "${palette.subtext0}";
        overlay2 = "${palette.overlay2}";
        overlay1 = "${palette.overlay1}";
        overlay0 = "${palette.overlay0}";
        surface2 = "${palette.surface2}";
        surface1 = "${palette.surface1}";
        surface0 = "${palette.surface0}";
        base = "${palette.base}";
        mantle = "${palette.mantle}";
        crust = "${palette.crust}";
      };

      character = {
        error_symbol = "[✗](bold sky)";
        success_symbol = "[❯](bold sky)";
      };

      directory = {
        truncation_length = 2;
        truncation_symbol = "…/";
        style = "bold sky";
        repo_root_style = "bold sky";
        repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "italic mauve";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status]($style))";
        style = "bold red";
        ahead = "⇡\${count} ";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        behind = "⇣\${count} ";
        conflicted = " ";
        up_to_date = " ";
        untracked = "? ";
        modified = " ";
      };
    };
  };
}
