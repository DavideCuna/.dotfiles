{ config, pkgs, ... }:
{
  programs.rofi = {
    # enable = true;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    font = "IosefkaTerm Nerd Font 13";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
    };
  };
}
