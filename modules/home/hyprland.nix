{ config, pkgs, ... }:
let
   palette = import ../../theme/palette.nix;
   c = palette.colors;

in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    settings = {
      # XWayland
      xwayland = {
        force_zero_scaling = true;
      };

      # Monitor configuration
      monitor = [
        "HDMI-A-1,preferred,0x-1440,1"
        "eDP-1,1920x1080,0x0,1"
      ];

      # Environment variables
      env = [
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,rose-pine-hyprcursor"
        "XCURSOR_SIZE,24"
      ];

      # Programs
      "$terminal" = "ghostty";
      "$fileManager" = "thunar";
      "$menu" = "rofi -show drun";
      "$mainMod" = "SUPER";

      # General settings
      general = {
        gaps_in = 4;
        gaps_out = 6;
        gaps_workspaces = 50;
        border_size = 3;
        "col.active_border" = "rgba(500a04ff) rgba(330a04ff) 30deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 7;
        rounding_power = 5;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          ignore_window = true;
          range = 30;
          render_power = 4;
          color = "rgba(00000010)";
        };

        blur = {
          enabled = true;
          xray = true;
          special = false;
          size = 7;
          passes = 2;
          brightness = 0.8;
          noise = 0.01;
          contrast = 1.1;
          popups = true;
          popups_ignorealpha = 0.6;
          vibrancy = 0.1696;
        };
      };

      # Animations
      animations = {
        enabled = true;

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global,1,10,default"
          "border,1,5.39,easeOutQuint"
          "windows,1,4.79,easeOutQuint"
          "windowsIn,1,4.1,easeOutQuint,popin 87%"
          "windowsOut,1,1.49,linear,popin 87%"
          "fadeIn,1,1.73,almostLinear"
          "fadeOut,1,1.46,almostLinear"
          "fade,1,3.03,quick"
          "layers,1,3.81,easeOutQuint"
          "layersIn,1,4,easeOutQuint,fade"
          "layersOut,1,1.5,linear,fade"
          "fadeLayersIn,1,1.79,almostLinear"
          "fadeLayersOut,1,1.39,almostLinear"
          "workspaces,1,1.94,almostLinear,fade"
          "workspacesIn,1,1.21,almostLinear,fade"
          "workspacesOut,1,1.94,almostLinear,fade"
        ];
      };

      # Dwindle layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout
      master = {
        new_status = "master";
      };

      # Misc
      misc = {
        force_default_wallpaper = 1;
        disable_hyprland_logo = true;
      };

      # Input
      input = {
        kb_layout = "it";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
        };
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
      };

      # Device specific
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # Keybindings
      bind = [
        "$mainMod,Q,exec,$terminal"
        "$mainMod,C,killactive,"
        "$mainMod,M,exit,"
        "$mainMod,F,fullscreen"
        "$mainMod,E,exec,$terminal -e $fileManager"
        "$mainMod,V,togglefloating,"
        "$mainMod,D,exec,$menu"
        "$mainMod,P,pseudo,"
        
        # Move focus
        "$mainMod,h,movefocus,l"
        "$mainMod,l,movefocus,r"
        "$mainMod,k,movefocus,u"
        "$mainMod,j,movefocus,d"
        
        # Special workspace
        "$mainMod,S,togglespecialworkspace,magic"
        "$mainMod SHIFT,S,movetoworkspace,special:magic"
        
        # Scroll workspaces
        "$mainMod,mouse_down,workspace,e+1"
        "$mainMod,mouse_up,workspace,e-1"
      ] ++ (
        # Generate workspace bindings for 1-9 using keycodes
        builtins.concatLists (builtins.genList (i:
          let
            ws = toString (i + 1);
            keycode = toString (i + 10);
          in [
            "$mainMod,code:${keycode},workspace,${ws}"
            "$mainMod SHIFT,code:${keycode},movetoworkspace,${ws}"
          ]
        ) 9)
      ) ++ [
        # Workspace 10 (keycode 19 = 0 key)
        "$mainMod,code:19,workspace,10"
        "$mainMod SHIFT,code:19,movetoworkspace,10"
      ];

      # Bind with repeat
      bindel = [
        ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp,exec,brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown,exec,brightnessctl -e4 -n2 set 5%-"
      ];

      # Bind for locked screen
      bindl = [
        ",XF86AudioNext,exec,playerctl next"
        ",XF86AudioPause,exec,playerctl play-pause"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioPrev,exec,playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod,mouse:272,movewindow"
        "$mainMod,mouse:273,resizewindow"
      ];

      # Window rules
      windowrule = [
        "suppressevent maximize,class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      # Autostart
      exec-once = [
        "waybar"
        "hyprpaper"
        "hyprctl setcursor rose-pine-hyprcursor 32"
        "$terminal"
      ];
    };
  };
}
