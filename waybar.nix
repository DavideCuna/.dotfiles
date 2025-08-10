{ config, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin-bottom = -10;
        spacing = 0;
        modules-left = [ "hyprland/workspaces" "tray" ];
        modules-center = [ "clock" "custom/pomodoro" ];
        modules-right = ["cpu" "memory" "network" "battery" ];
      };

      "custom/pomodoro" = {
        format = "{}";
        return-type = "json";
        exec = "/home/davide/.local/bin/pomodoro.sh";
        on-click = "/home/davide/.local/bin/pomodoro.sh start";
        on-click-right = "/home/davide/.local/bin/pomodoro.sh reset";
        interval = 1;
      };

    };

    style = '' 

      @define-color accent #190A04; 
      @define-color fg #4B4B46;
      @define-color bg #222C2D;
      @define-color bg-alt #1D2526;

    * {
        font-size: 11px;
        min-height: 0;
      }

      #mode {
        font-family: "IosevkaTerm Nerd Font";
        font-weight: bold;
        color: @accent;
      }

        window#waybar {
          background-color: @bg;
          border-bottom: 1px solid @bg-alt;
        }

        workspaces {
          font-family: "IosevkaTerm Nerd Font";
          border-bottom: 1px solid @bg-alt;
        }

        workspaces button {
          padding: 7px 12px 7px 12px;
          color: @fg;
          background-color: @bg;
          border: none;
        }

        workspaces button:hover {
          background: none;
          border: none;
          border-color: transparent;
          transition: none;
        }

        workspaces button.focused {
          border-radius: 0;
          color: @accent;
          font-weight: bold;
        }

        #custom-pomodoro {
          color: @accent;
          background: @bg;
          border-radius: 6px;
          padding: 0 10px;
          margin: 0 4px;
          font-weight: bold;
        }

        #custom-pomodoro.done {
          background: @bg-alt;
          color: @accent;
          animation: blink 1s steps(2, start) infinite;
        }

        @keyframes blink {
          to {
            color: transparent;
          }
        }

    '';
  };
}
