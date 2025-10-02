{ config, pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    settings = lib.mkForce {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 12;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [
          "cpu"
          "memory"
          "network"
          "pulseaudio"
          "backlight"
          "battery"
        ];
				# };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 Mute";
        format-icons = {
          headphones = "󰋋";
          default = ["󰕾" "󰖀" "󰕿"];
        };
        on-click = "pavucontrol";
        scroll-step = 5;
      };

      "backlight" = {
        format = "{icon} {percent}%";
        format-icons = [ "󰃭" "󰃬" "󰃫" ];
        device = "intel_backlight";
        on-scroll-up = "brightnessctl set +5%";
        on-scroll-down = "brightnessctl set 5%-";
      };

      "battery" = {
        states = {
          good = 80;
          warning = 40;
          critical = 20;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰂂" "󰂄" ];
        format-plugged = "󰂄 {capacity}%";
        format-critical = "󰂃 {capacity}%";
      };
    };
		};

    style = ''
      /* Color palette */
      @define-color accent #a8733f;      /* cannella */
      @define-color brown #6e3b1e;       /* marrone */
      @define-color rust #b94c2b;        /* rossiccio */
      @define-color dark #191411;        /* nero */
      @define-color metal #7e7e7e;       /* grigio metallico */
      @define-color bg @dark;
      @define-color bg-alt #26211c;
      @define-color fg #e7e0d7;
      @define-color warning #b94c2b;
      @define-color critical #a80000;

      * {
        font-size: 13px;
        font-family: "IosevkaTerm Nerd Font", "Symbols Nerd Font", monospace;
        min-height: 0;
      }

      window#waybar {
        background: @bg;
        color: @fg;
        border-bottom: 2px solid @brown;
      }

      /* ISLANDS */
      .modules-left, .modules-center, .modules-right {
        background: @bg-alt;
        border-radius: 12px;
        margin: 4px 0 0 0;
        padding: 4px 10px;
        box-shadow: 0 2px 8px 0 rgba(30, 20, 10, 0.12);
        border: 1px solid @metal;
      }

      /* Workspaces */
      #workspaces {
        font-family: "Symbols Nerd Font", "IosevkaTerm Nerd Font";
      }
      #workspaces button {
        color: @fg;
        background: transparent;
        border: none;
        padding: 6px 14px;
        font-weight: normal;
      }
      #workspaces button.active {
        color: @accent;
        font-weight: bold;
        background: @brown;
        border-radius: 6px;
      }
      #workspaces button.urgent {
        color: @critical;
        background: @rust;
        border-radius: 6px;
      }

      /* Window title */
      #window {
        color: @metal;
        font-weight: bold;
        padding-right: 16px;
      }

      /* Clock */
      #clock {
        color: @accent;
        font-weight: bold;
        letter-spacing: 1px;
        padding: 0 8px;
      }

      /* Pomodoro */
      #custom-pomodoro {
        color: @rust;
        background: @bg-alt;
        border-radius: 6px;
        padding: 0 12px;
        margin: 0 4px;
        font-weight: bold;
      }
      #custom-pomodoro.done {
        background: @brown;
        color: @critical;
        animation: blink 1s steps(2, start) infinite;
      }
      @keyframes blink {
        to { color: transparent; }
      }

      /* CPU, Memory, Network */
      #cpu, #memory, #network {
        color: @fg;
        background: transparent;
        font-weight: bold;
        padding: 0 8px;
      }
      #network.disconnected {
        color: @critical;
      }

      /* Volume */
      #pulseaudio {
        color: @accent;
        font-weight: bold;
        padding: 0 8px;
      }
      #pulseaudio.muted {
        color: @rust;
      }

      /* Brightness */
      #backlight {
        color: @metal;
        font-weight: bold;
        padding: 0 8px;
      }

      /* Battery */
      #battery {
        color: @accent;
        background: @bg-alt;
        border-radius: 7px;
        padding: 0 10px;
        font-weight: bold;
        transition: background 0.2s;
      }
      #battery.charging, #battery.plugged {
        color: @rust;
        background: @brown;
      }
      #battery.warning {
        color: @warning;
        background: @bg-alt;
      }
      #battery.critical {
        color: @critical;
        background: @rust;
        animation: blink 1s steps(2, start) infinite;
      }
    '';
  };
}
