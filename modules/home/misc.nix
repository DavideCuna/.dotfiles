{ pkgs, ... }:
{
   home.packages = with pkgs; [
      calcure
      nautilus
      discord
      krabby
      libreoffice-qt6
   ];
}
