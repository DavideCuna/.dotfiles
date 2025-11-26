{ config, pkgs, lib, ... }:

let
  myAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    cp = "cp -i";
    uni = "cd /home/davide/Desktop/Uni_work";
  };
  palette = import ./theme/palette.nix;
in {
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = myAliases;

      oh-my-zsh = {
        enable = true;
        theme = "half-life";
        plugins = [ "git" ];
      };
    };
  };
}
