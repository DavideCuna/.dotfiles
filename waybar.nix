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
        exec = "${config.home.homeDirectory}/.local/bin/pomodoro.sh";
        on-click = "${config.home.homeDirectory}/.local/bin/pomodoro.sh start";
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

    '';
  };
}
