{ config, pkgs, lib, ... }:
let
  palette = import ./theme/palette.nix;
  c = palette.colors;

  # Volume script (wpctl)
  volumeScript = pkgs.writeShellScript "waybar-volume" ''
    set -u
    get_status() {
      wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true
    }
    get_star_sink_line() {
      wpctl status | awk '/Sinks:/{f=1;next} /Sources:/{f=0} f && /\*/{print; exit}'
    }

    status="$(get_status)"
    if [ -z "$status" ]; then
      echo '{"text":"[AUDIO_ERR]","class":"error","tooltip":"No default sink"}'
      exit 0
    fi

    muted=0
    if echo "$status" | grep -q 'MUTED'; then muted=1; fi

    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{ if (v+0<0) v=0; if (v>5) v=5; printf "%d", v*100+0.5 }')"

    if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
      text="[MUTED]"; class="muted"
    else
      text="[VOL:$pct%]"
      if    [ "$pct" -le 30 ]; then class="low"
      elif [ "$pct" -le 70 ]; then class="mid"
      else class="high"
      fi
    fi

    sinkLine="$(get_star_sink_line)"
    sinkName="$(printf "%s" "$sinkLine" | tr -d '│' | sed -E 's/.*\* *[0-9]+\.\s*//; s/\s*\[vol:.*//')"
    [ -z "$sinkName" ] && sinkName="Unknown"

    tooltip=">>OUTPUT: $sinkName\n>>LEVEL: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip\n>>STATUS: MUTED"

    tooltipEscaped="$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g')"

    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
      "$text" "$class" "$tooltipEscaped"
  '';

  # Mic script (wpctl)
  micScript = pkgs.writeShellScript "waybar-mic" ''
    set -u
    get_status() {
      wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true
    }
    get_star_source_line() {
      wpctl status | awk '/Sources:/{f=1;next} /Filters:/{f=0} f && /\*/{print; exit}'
    }

    status="$(get_status)"
    if [ -z "$status" ]; then
      echo '{"text":"[MIC_ERR]","class":"error","tooltip":"No default source"}'
      exit 0
    fi

    muted=0
    if echo "$status" | grep -q 'MUTED'; then muted=1; fi

    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{ if (v+0<0) v=0; if (v>5) v=5; printf "%d", v*100+0.5 }')"

    if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
      text="[MIC:OFF]"; class="muted"
    else
      text="[MIC:$pct%]"
      if    [ "$pct" -le 30 ]; then class="low"
      elif [ "$pct" -le 70 ]; then class="mid"
      else class="high"
      fi
    fi

    srcLine="$(get_star_source_line)"
    srcName="$(printf "%s" "$srcLine" | tr -d '│' | sed -E 's/.*\* *[0-9]+\.\s*//; s/\s*\[vol:.*//')"
    [ -z "$srcName" ] && srcName="Unknown"

    tooltip=">>INPUT: $srcName\n>>LEVEL: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip\n>>STATUS: MUTED"

    tooltipEscaped="$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g')"

    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
      "$text" "$class" "$tooltipEscaped"
  '';

  # Device picker
  pickerScript = pkgs.writeShellScript "waybar-audio-picker" ''
    mode="$1"
    [ -z "$mode" ] && mode="sink"
    list="$(wpctl status)"
    if [ "$mode" = "sink" ]; then
      section="Sinks:"
      stop="Sources:"
    else
      section="Sources:"
      stop="Clients:"
    fi
    entries="$(printf "%s" "$list" | awk -v sec="$section" -v stop="$stop" '
      $0 ~ sec {f=1;next}
      $0 ~ stop {f=0}
      f && /^[[:space:]]*\*?[[:space:]]*[0-9]+\./ {
        line=$0
        gsub(/│/,"",line)
        sub(/^[[:space:]]*/,"",line)
        mark=""
        if (substr(line,1,1)=="*") { mark=">> "; sub(/^\*/,"",line); sub(/^[[:space:]]*/,"",line) }
        id=line
        sub(/\..*/,"",id)
        desc=line
        sub(/^[0-9]+\.[[:space:]]*/,"",desc)
        sub(/\[vol:.*$/,"",desc)
        gsub(/[[:space:]]+$/,"",desc)
        print mark id " | " desc
      }')"

    if [ -z "$entries" ]; then
      command -v notify-send >/dev/null && notify-send ">>AUDIO" "No $mode devices found"
      exit 0
    fi
    if [ "$(printf "%s" "$entries" | wc -l)" -le 1 ]; then
      command -v notify-send >/dev/null && notify-send ">>AUDIO" "Only one $mode device"
      exit 0
    fi
    choice="$(echo "$entries" | rofi -dmenu -p ">>SELECT_$mode")"
    [ -z "$choice" ] && exit 0
    id="$(printf "%s" "$choice" | sed 's/^>> //;s/ |.*//')"
    wpctl set-default "$id"
    command -v notify-send >/dev/null && notify-send ">>AUDIO" "Default $mode set to ID:$id"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  # Volume sliders
  mkSliderBar = pkgs.writeShellScript "gen-bar" ''
    p=$1
    segs=20
    filled=$(( (p*segs)/100 ))
    [ $filled -gt $segs ] && filled=$segs
    bar="$(printf '%*s' "$filled" "" | tr ' ' '█')"
    unfilled=$(( segs - filled ))
    bar="$bar$(printf '%*s' "$unfilled" "" | tr ' ' '░')"
    printf "[%s] %3d%%" "$bar" "$p"
  '';

  volumeSlider = pkgs.writeShellScript "waybar-volume-slider" ''
    cur=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')
    curPct=$(awk -v v="$cur" 'BEGIN{printf "%d", v*100+0.5}')
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line=">> $line"
      else
        line="   $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p '>>OUTPUT_VOL' | sed 's/^>> //;s/^   //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$sel%"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  micSlider = pkgs.writeShellScript "waybar-mic-slider" ''
    cur=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{print $2}')
    curPct=$(awk -v v="$cur" 'BEGIN{printf "%d", v*100+0.5}')
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line=">> $line"
      else
        line="   $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p '>>MIC_LEVEL' | sed 's/^>> //;s/^   //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ "$sel%"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  brightnessSlider = pkgs.writeShellScript "waybar-brightness-slider" ''
    max=$(brightnessctl m 2>/dev/null)
    curRaw=$(brightnessctl g 2>/dev/null)
    [ -z "$max" ] || [ -z "$curRaw" ] && exit 0
    curPct=$(( curRaw * 100 / max ))
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line=">> $line"
      else
        line="   $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p '>>BRIGHTNESS' | sed 's/^>> //;s/^   //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    brightnessctl set "$sel%" -q
  '';
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 0;
        output = [ "eDP-1" "HDMI-A-1" ];

        # Layout: System info left, workspaces center, status right
        modules-left   = [ "custom/logo" "cpu" "memory" "custom/battery" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right  = [ "network" "custom/volume" "custom/mic" "backlight" "clock" ];

        "custom/logo" = {
          format = ">>雪花";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "[{id}]";
          on-click = "activate";
          all-outputs = false;
          active-only = false;
        };

        clock = {
          interval = 1;
          format = "[{:%H:%M:%S}]";
          format-alt = "[{:%Y.%m.%d}]";
          tooltip-format = ">>PRESENT_DAY\n>>PRESENT_TIME\n\n{:%Y-%m-%d %H:%M:%S}";
        };

        cpu = {
          format = "[CPU:{usage}%]";
          interval = 2;
          states = { warning = 70; critical = 90; };
        };

        memory = {
          format = "[MEM:{percentage}%]";
          interval = 5;
          states = { warning = 70; critical = 85; };
        };

        network = {
          interval = 5;
          format-wifi = "[NET:{essid}]";
          format-ethernet = "[NET:WIRED]";
          format-disconnected = "[NET:DOWN]";
          tooltip-format = ">>SSID: {essid}\n>>SIGNAL: {signalStrength}%\n>>IP: {ipaddr}";
          on-click = "${pkgs.kitty}/bin/kitty -e nmtui";
        };

        backlight = {
          format = "[BRI:{percent}%]";
          interval = 2;
          on-click-middle = "${brightnessSlider}";
          on-scroll-up = "brightnessctl set 5%+ -q";
          on-scroll-down = "brightnessctl set 5%- -q";
        };

        "custom/volume" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec = "${volumeScript}";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          on-click-right = "${pickerScript} sink";
          on-click-middle = "${volumeSlider}";
        };

        "custom/mic" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec = "${micScript}";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-scroll-up = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
          on-click-right = "${pickerScript} source";
          on-click-middle = "${micSlider}";
        };

        "custom/battery" = {
          interval = 1;
          return-type = "json";
          format = "{}";
          on-click-right = "${pkgs.bash}/bin/bash -c 'if command -v powerprofilesctl >/dev/null; then cur=$(powerprofilesctl get); case $cur in performance) nxt=balanced;; balanced) nxt=power-saver;; power-saver) nxt=performance;; *) nxt=balanced;; esac; powerprofilesctl set \"$nxt\"; notify-send \">>POWER\" \"Profile: $nxt\"; fi'";
          exec = ''
            ${pkgs.bash}/bin/bash -c '
            cap_file=/sys/class/power_supply/BAT0/capacity
            status_file=/sys/class/power_supply/BAT0/status
            if [ -r "$cap_file" ]; then cap=$(cat "$cap_file"); else cap="?"; fi
            if [ -r "$status_file" ]; then st=$(cat "$status_file"); else st="Unknown"; fi

            text="[BAT:$cap%]"
            classes=$(echo "$st" | tr "A-Z" "a-z")
            
            if [ "$cap" != "?" ]; then
              if [ "$cap" -le 10 ]; then classes="$classes critical"
              elif [ "$cap" -le 25 ]; then classes="$classes warning"
              fi
            fi

            profile=""
            if command -v powerprofilesctl >/dev/null; then
              profile=$(powerprofilesctl get 2>/dev/null)
            fi

            tooltip=">>STATUS: $st\n>>CAPACITY: $cap%"
            [ -n "$profile" ] && tooltip="$tooltip\n>>PROFILE: $profile"

            printf '"'"'{"text":"%s","tooltip":"%s","class":"%s"}\n'"'"' \
              "$text" "$(printf %s "$tooltip" | sed '"'"'s/"/\\"/g'"'"')" "$classes"
            '
          '';
        };
      };
    };

    style = ''
      /* Lain Aesthetic - Cyberpunk Terminal */
      @define-color lain-fg       ${c.fg};
      @define-color lain-fg-dim   ${c.fgAlt};
      @define-color lain-bg       ${c.bg};
      @define-color lain-bg-alt   ${c.bgAlt};
      @define-color lain-border   ${c.border};
      @define-color lain-accent   ${c.cyan};
      @define-color lain-accentB  ${c.cyanBright};
      @define-color lain-warn     ${c.warn};
      @define-color lain-error    ${c.error};
      @define-color lain-ok       ${c.ok};

      * {
        font-size: 15px;
        font-family: "IosevkaTerm Nerd Font";
        min-height: 3px;
        border: none;
        border-radius: 3px;
      }

      window#waybar {
        background: 
          repeating-linear-gradient(
            0deg,
            rgba(0, 0, 0, 0.15) 0px,
            transparent 1px,
            transparent 2px
          ),
          rgba(0, 0, 0, 0.85);
        color: @lain-fg;
        border-bottom: 1px solid @lain-border;
        padding: 0;
        margin: 0;
      }

      /* Logo/System ID */
      #custom-logo {
        padding: 0 12px;
        background: @lain-bg;
        color: @lain-accentB;
        font-weight: normal;
        border-right: 1px solid @lain-border;
        letter-spacing: 1px;
      }

      /* System monitors */
      #cpu,
      #memory,
      #custom-battery {
        padding: 0 10px;
        color: @lain-fg;
        background: transparent;
        border-right: 1px solid @lain-border;
      }

      #cpu.warning,
      #memory.warning,
      #custom-battery.warning {
        color: @lain-warn;
        animation: blink-warning 2s ease-in-out infinite;
      }

      #cpu.critical,
      #memory.critical,
      #custom-battery.critical {
        color: @lain-error;
        animation: blink-critical 1s ease-in-out infinite;
      }

      #custom-battery.charging { color: @lain-accentB; }
      #custom-battery.full { color: @lain-accent; }

      /* Workspaces - Center, minimal */
      #workspaces {
        padding: 0 8px;
        background: transparent;
      }

      #workspaces button {
        padding: 0 6px;
        color: @lain-fg-dim;
        background: transparent;
        transition: all 0.2s ease;
      }

      #workspaces button.active {
        color: @lain-accent;
        font-weight: bold;
        text-shadow: 0 0 8px @lain-accent;
      }

      #workspaces button:hover {
        color: @lain-fg;
        background: @lain-bg-alt;
      }

      #workspaces button.urgent {
        color: @lain-error;
        animation: blink-urgent 0.5s ease-in-out infinite;
      }

      /* Right side modules */
      #network,
      #custom-volume,
      #custom-mic,
      #backlight,
      #clock {
        padding: 0 10px;
        color: @lain-fg;
        background: transparent;
        border-left: 1px solid @lain-border;
      }

      /* Audio states */
      #custom-volume.muted,
      #custom-mic.muted {
        color: @lain-error;
      }

      #custom-volume.high,
      #custom-mic.high {
        color: @lain-accent;
      }

      /* Clock - special highlight */
      #clock {
        color: @lain-accent;
        font-weight: bold;
        border-left: 1px solid @lain-accent;
        letter-spacing: 0.5px;
      }

      /* Network state */
      #network.disconnected {
        color: @lain-error;
      }

      /* Animations */
      @keyframes blink-warning {
        0% { opacity: 1; }
        50% { opacity: 0.5; }
        100% { opacity: 1; }
      }

      @keyframes blink-critical {
        0% { opacity: 1; }
        50% { opacity: 0.3; }
        100% { opacity: 1; }
      }

      @keyframes blink-urgent {
        0% { opacity: 1; }
        50% { opacity: 0.4; }
        100% { opacity: 1; }
      }

      /* Optional: Add scanline texture to background if you want */
      window#waybar {
        background: 
          repeating-linear-gradient(
            0deg,
            rgba(0, 0, 0, 0.15) 0px,
            transparent 1px,
            transparent 2px
          ),
          rgba(0, 0, 0, 0.85);
      }
    '';
  };
}
