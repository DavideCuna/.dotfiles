{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [waybar];

  environment.etc."waybar/config".text = ''{
    "layer": "top",
    "modules-left": [ "hyprland/workspaces" ],
    "modules-center": [ "clock" ],
    "modules-right": ["cpu" "memory" "network" "battery" "tray"],
    # style
  }'';
}
