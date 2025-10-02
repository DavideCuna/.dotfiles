{ config, pkgs, ... }:

let
  myAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    cp = "cp -i";
    ycd = "cd \"$(yazi --print-cwd)\"";
  };
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

      # Override colori del tema usando la palette globale
      initExtra = ''
        # Palette colori importata dal modulo colorscheme.nix
        export ZSH_ACCENT='${palette.colorscheme.accent}'
        export ZSH_BROWN='${palette.colorscheme.brown}'
        export ZSH_RUST='${palette.colorscheme.rust}'
        export ZSH_DARK='${palette.colorscheme.dark}'
        export ZSH_METAL='${palette.colorscheme.metal}'
        export ZSH_BG='${palette.colorscheme.bg}'
        export ZSH_BGALT='${palette.colorscheme.bgAlt}'
        export ZSH_FG='${palette.colorscheme.fg}'
        export ZSH_WARNING='${palette.colorscheme.warning}'
        export ZSH_CRITICAL='${palette.colorscheme.critical}'

        # Prompt custom che usa la palette
        PROMPT='%F{$ZSH_ACCENT}%n%f at %F{$ZSH_BROWN}%~%f %F{$ZSH_RUST}$ %f'
        # Se usi powerlevel10k, puoi referenziare queste variabili nei segmenti custom!
      '';
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
