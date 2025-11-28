{ config, pkgs, lib, ... }:
let
  palette = import ./theme/palette.nix;
  c = palette.colors;
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 0;
        no_fade_in = false;
        no_fade_out = false;
        fail_timeout = 750;
      };

      auth = {
            "fingerprint:enabled" = true;
            "fingerprint:ready_message" = ">>READY_TO_SCAN";
            "fingerprint:present_message" = ">>>SCANNING";
      };

      background = [
        {
          monitor = "";
          path = "../Pictures/wallpapers/lain9.jpeg";
          blur_passes = 2;
          blur_size = 4;
          noise = 0.0175;
          contrast = 0.8916;
          brightness = 0.7;
          vibrancy = 0.1730;
          vibrancy_darkness = 0.3;
        }
      ];

      # Scanline overlay effect
      image = [
        {
          monitor = "";
          path = "";
          size = 0;
          rounding = -1;
          border_size = 0;
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
      ];

      # System status label (top-left)
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo '>>SYSTEM_STATUS: LOCKED'";
          color = "rgba(${c.cyanBright}FF)";
          font_size = 14;
          font_family = "IosevkaTerm Nerd Font";
          position = "20, -20";
          halign = "left";
          valign = "top";
        }
        # Date/Time (top-right)
        {
          monitor = "";
          text = "cmd[update:1000] date '+>>%Y.%m.%d'";
          color = "rgba(${c.fg}FF)";
          font_size = 15;
          font_family = "IosevkaTerm Nerd Font";
          position = "-20, -20";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:1000] date '+[%H:%M:%S]'";
          color = "rgba(${c.cyanBright}FF)";
          font_size = 21;
          font_family = "IosevkaTerm Nerd Font Bold";
          position = "-20, -45";
          halign = "right";
          valign = "top";
        }
        # Welcome message (center-top)
        {
          monitor = "";
          text = ">>雪花 AUTHENTICATION_REQUIRED";
          color = "rgba(${c.cyanBright}FF)";
          font_size = 25;
          font_family = "IosevkaTerm Nerd Font Bold";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        # User prompt
        {
          monitor = "";
          text = ">>USER: $USER";
          color = "rgba(${c.fg}FF)";
          font_size = 14;
          font_family = "IosevkaTerm Nerd Font";
          position = "0, 20";
          halign = "center";
          valign = "center";
        }
        # Failed attempts indicator
        {
          monitor = "";
          text = "cmd[update:1000] echo '>>AUTH_FAILS: <b>$ATTEMPTS</b>'";
          color = "rgba(${c.error}FF)";
          font_size = 12;
          font_family = "IosevkaTerm Nerd Font";
          position = "0, -140";
          halign = "center";
          valign = "center";
        }
        # Battery status (bottom-left)
        {
          monitor = "";
          text = "cmd[update:5000] ${pkgs.bash}/bin/bash -c 'cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo \"?\"); st=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo \"N/A\"); echo \">>BAT:$cap% [$st]\"'";
          color = "rgba(${c.fg}FF)";
          font_size = 12;
          font_family = "IosevkaTerm Nerd Font";
          position = "20, 40";
          halign = "left";
          valign = "bottom";
        }
        # Network status (bottom-right)
        {
          monitor = "";
          text = "cmd[update:5000] ${pkgs.bash}/bin/bash -c 'if ip link show | grep -q \"state UP\"; then echo \">>NET:CONNECTED\"; else echo \">>NET:DISCONNECTED\"; fi'";
          color = "rgba(${c.fg}FF)";
          font_size = 12;
          font_family = "IosevkaTerm Nerd Font";
          position = "-20, 40";
          halign = "right";
          valign = "bottom";
        }
      ];

      # Password input field
      input-field = [
        {
          monitor = "";
          size = "350, 60";
          outline_thickness = 2;
          dots_size = 0.25;
          dots_spacing = 0.4;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "rgba(${c.border}FF)";
          inner_color = "rgba(${c.bg}DD)";
          font_color = "rgba(${c.fg}FF)";
          fade_on_empty = false;
          fade_timeout = 1000;
          placeholder_text = "<span foreground='#${c.fgAlt}'>[ >>ENTER_PASSWORD ]</span>";
          hide_input = false;
          rounding = 3;
          check_color = "rgba(${c.cyan}FF)";
          fail_color = "rgba(${c.error}FF)";
          fail_text = "<span foreground='#${c.error}'>>>ACCESS_DENIED</span>";
          fail_transition = 300;
          capslock_color = "rgba(${c.warn}FF)";
          numlock_color = -1;
          bothlock_color = -1;
          invert_numlock = false;
          swap_font_color = false;
          position = "0, -50";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 4;
          shadow_color = "rgba(0, 0, 0, 0.5)";
        }
      ];
    };
  };
}
