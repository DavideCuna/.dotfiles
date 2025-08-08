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

  wayland.windowManager.hyprland.settings = {
    bind = [
      "SUPER, R, exec, rofi -show drun"
      "SUPER, F, exec, rofi -show window"
    ];
  };
}
