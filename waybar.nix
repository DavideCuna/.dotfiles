{ config, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      "layer" = "top";
      "modules-left" = [ "hyprland/workspaces" ];
      "modules-center" = [ "clock" ];
      "modules-right" = ["network" "battery" "tray"];

    };
    # style
  };

  environment.systemPackages = with pkgs; [waybar];

}
