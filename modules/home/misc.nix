{ pkgs, ... }:
{
   home.packages = with pkgs; [
      calcure
      discord
      krabby
      libreoffice-qt6
   ];
}
