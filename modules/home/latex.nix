{ pkgs, ... }:
{
   home.packages = with pkgs; [
      texliveFull
      sioyek
      texlab
   ];
}
