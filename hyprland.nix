{ config, pkgs, ...}:
{
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
