{ config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-hard";
  };

  environment.systemPackages = with pkgs; [rofi-wayland];

}
