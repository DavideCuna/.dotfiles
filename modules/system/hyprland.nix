{ pkgs, ... }:
{
   environment.systemPackages = with pkgs; [
      hyprland
      hyprpaper
      # hyprlock
      hyprcursor
      rose-pine-cursor
      hyprshot
      greetd.tuigreet
      rofi-wayland
      wl-clipboard-rs
      brightnessctl
      xdg-desktop-portal-hyprland
      pipewire
   ];
}
