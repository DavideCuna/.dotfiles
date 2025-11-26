{ pkgs, ... }:
{
   home.packages = with pkgs; [
      calcure
      xfce.thunar
      xfce.thunar-volman
      discord
      krabby
      libreoffice-qt6
   ];
}
