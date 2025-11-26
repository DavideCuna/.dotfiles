{ config, pkgs, ... }:
{
   home.packages = with pkgs; [
      bitwarden-menu
   ];

  programs.rofi = {
    # enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    font = "IosefkaTerm Nerd Font 13";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
    };
  };
}
