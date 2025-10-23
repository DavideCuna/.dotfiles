{ pkgs, ... }:
{
   home.packages = with pkgs; [
      jetbrains.idea-community
      arduino-ide
      android-studio
   ];
}
