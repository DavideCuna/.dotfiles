{ config, pkgs, ...}:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = [
      "$mod, F, exec, firefox"
      "$mod, R, exec, rofi -show drun"
    ]
      ++ (
        builtins.concatLists (builtins.genList (i:
          let
            ws = toString (i + 1);
          in [
            "$mod, code:1${ws}, workspace, ${ws}"
            "$mod SHIFT, code:1${ws}, movetoworkspace, ${ws}"
             ]
          ) 9)
      );
    };
}
