{ config, pkgs, ...}:
{
  programs.hyprland = {
    enable = true;
    
  };

  environment.systemPackages = with pkgs; [
    hyprland
    hyprpaper
    hyprlock
  ];

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayand";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_NO_HARDWARE_CURSOR = "1";
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = [
      "$mod, F, exec, firefox"
      
    ]
      ++ (
        builtins.concatList (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, &{toString ws}"
          ]
        ) 9)
      );
  };
}
