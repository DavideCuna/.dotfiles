{ config, pkgs, ... }:
{
  programs.rofi = {
    # enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
    };
    theme = "gruvbox-dark";
  };
}
