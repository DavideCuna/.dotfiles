{ config, pkgs, lib, ... }:

let
  myAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    cp = "cp -i";
    uni = "cd /home/davide/Desktop/Uni_work";
  };
  palette = import ./stylix.nix;
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

    kitty = {
      enable = true;
      extraConfig = ''
        background_opacity 0.37
        background_blur 1
        font_family IosevkaTerm Nerd Font
        font_size 12
        show_hyperlink_targets yes
        background #0e1419
        foreground #e5e1cf
        cursor #f19618
        selection_background #243340
        color0 #000000
        color8 #323232
        color1 #ff3333
        color9 #ff6565
        color2 #b8cc52
        color10 #e9fe83
        color3 #e6c446
        color11 #fff778
        color4 #36a3d9
        color12 #68d4ff
        color5 #f07078
        color13 #ffa3aa
        color6 #95e5cb
        color14 #c7fffc
        color7 #ffffff
        color15 #ffffff
        selection_foreground #0e1419
      '';
    };
  };
}
