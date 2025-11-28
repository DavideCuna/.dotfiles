{ config, pkgs, lib, ... }:
let
  palette = import ./theme/palette.nix;
  c = palette.colors;
  
  # Icon theme configuration
  iconTheme = "Nordzy-dark";
  iconPackage = pkgs.nordzy-icon-theme;
  
  # Convert hex to rgba format for Rofi (hex without #)
  hexToRgba = hex: opacity: 
    let
      # Remove # if present
      cleanHex = lib.removePrefix "#" hex;
    in
    "${cleanHex}${opacity}";
in
{
  # Install icon theme
  home.packages = [ iconPackage ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    
    font = "IosevkaTerm Nerd Font 12";
    
    extraConfig = {
      modi = "drun,run,window,ssh";
      show-icons = true;
      icon-theme = iconTheme;
      display-drun = ">>APPS";
      display-run = ">>RUN";
      display-window = ">>WINDOWS";
      display-ssh = ">>SSH";
      drun-display-format = "[{name}]";
      window-format = "[{w}] {c} {t}";
      
      # Layout
      width = 35;
      lines = 10;
      columns = 1;
      
      # Behavior
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
      case-sensitive = false;
      cycle = true;
      
      # Keybindings
      kb-mode-next = "Shift+Right,Control+Tab";
      kb-mode-previous = "Shift+Left,Control+ISO_Left_Tab";
      kb-row-up = "Up,Control+k";
      kb-row-down = "Down,Control+j";
      kb-accept-entry = "Return,KP_Enter";
      kb-remove-to-eol = "Control+Shift+e";
      kb-mode-complete = "";
      kb-cancel = "Escape";
    };

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg = mkLiteral "#${hexToRgba c.bg "F0"}";
        bg-alt = mkLiteral "#${hexToRgba c.bgAlt "FF"}";
        fg = mkLiteral "#${hexToRgba c.fg "FF"}";
        fg-alt = mkLiteral "#${hexToRgba c.fgAlt "FF"}";
        
        accent = mkLiteral "#${hexToRgba c.cyan "FF"}";
        accent-bright = mkLiteral "#${hexToRgba c.cyanBright "FF"}";
        border-color = mkLiteral "#${hexToRgba c.border "FF"}";
        urgent = mkLiteral "#${hexToRgba c.error "FF"}";
        active = mkLiteral "#${hexToRgba c.ok "FF"}";
        
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        
        margin = 0;
        padding = 0;
        spacing = 0;
      };

      "window" = {
        location = mkLiteral "center";
        width = 650;
        background-color = mkLiteral "@bg";
        border = 2;
        border-color = mkLiteral "@border-color";
        border-radius = 4;
      };

      "mainbox" = {
        padding = 16;
        children = map mkLiteral [ "inputbar" "message" "listview" "mode-switcher" ];
      };

      "inputbar" = {
        padding = mkLiteral "8px 12px";
        spacing = 12;
        background-color = mkLiteral "@bg-alt";
        border = 1;
        border-color = mkLiteral "@border-color";
        border-radius = 3;
        children = map mkLiteral [ "prompt" "entry" ];
      };

      "prompt" = {
        text-color = mkLiteral "@accent-bright";
        font = "IosevkaTerm Nerd Font Bold 13";
      };

      "entry" = {
        placeholder = ">>SEARCH...";
        placeholder-color = mkLiteral "@fg-alt";
        cursor = mkLiteral "text";
      };

      "message" = {
        margin = mkLiteral "8px 0 0";
        padding = 8;
        background-color = mkLiteral "@bg-alt";
        border = 1;
        border-color = mkLiteral "@border-color";
        border-radius = 3;
      };

      "textbox" = {
        text-color = mkLiteral "@fg";
      };

      "listview" = {
        margin = mkLiteral "8px 0 0";
        lines = 10;
        columns = 1;
        fixed-height = false;
        scrollbar = true;
        spacing = 4;
      };

      "scrollbar" = {
        width = 4;
        padding = 0;
        handle-width = 4;
        border = 0;
        handle-color = mkLiteral "@accent";
        background-color = mkLiteral "@bg-alt";
      };

      "element" = {
        padding = mkLiteral "8px 12px";
        spacing = 12;
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        border-radius = 3;
      };

      "element normal.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      "element alternate.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      "element selected.normal" = {
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@accent-bright";
        border = 1;
        border-color = mkLiteral "@accent";
      };

      "element normal.urgent" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@urgent";
      };

      "element selected.urgent" = {
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@urgent";
        border = 1;
        border-color = mkLiteral "@urgent";
      };

      "element normal.active" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@active";
      };

      "element selected.active" = {
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@active";
        border = 1;
        border-color = mkLiteral "@active";
      };

      "element-icon" = {
        size = 24;
        vertical-align = mkLiteral "0.5";
      };

      "element-text" = {
        vertical-align = mkLiteral "0.5";
        text-color = mkLiteral "inherit";
      };

      "mode-switcher" = {
        margin = mkLiteral "8px 0 0";
        spacing = 8;
      };

      "button" = {
        padding = mkLiteral "10px 16px";
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@fg-alt";
        border = 1;
        border-color = mkLiteral "@border-color";
        border-radius = 3;
      };

      "button selected" = {
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@accent-bright";
        border-color = mkLiteral "@accent";
      };

      "error-message" = {
        padding = 12;
        background-color = mkLiteral "@bg";
        border = 2;
        border-color = mkLiteral "@urgent";
        border-radius = 4;
      };
    };
  };
}
