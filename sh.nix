{ config, pkgs, ... }:

let
  myAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    cp = "cp -i";
  };
in {
  programs = { 
    bash = {
      enable = true;
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
