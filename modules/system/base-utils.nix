{ pkgs, ... }:
{
   environment.systemPackages = with pkgs; [
      fd
      ripgrep
      gnumake
      jdk24
      gcc
      clang-tools
      arduino-cli
      postgresql
      zotero
      evince
      dia
      umlet
      thunderbird
   ];
}
