{ config, pkgs, lib, ... }:
let
  # ------------------------------------------------------------------
  # Variabili per Palette e Script (Senza Modifiche Agli Script)
  # ------------------------------------------------------------------
  # Assumi che 'palette' importi il file con i colori aggiornati.
  palette = import ./theme/palette.nix;
  c = palette.colors;

  # Volume script (default sink) – (MANTENUTO INVARIATO)
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
      echo '{"text":" ?","class":"error","tooltip":"No default sink"}'
      exit 0
    fi

    muted=0
    if echo "$status" | grep -q 'MUTED'; then muted=1; fi

    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{ if (v+0<0) v=0; if (v>5) v=5; printf "%d", v*100+0.5 }')"

    if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
      icon=""; class="muted"
    else
      if    [ "$pct" -le 30 ]; then icon=""; class="low"
      elif [ "$pct" -le 70 ]; then icon=""; class="mid"
      elif [ "$pct" -le 100 ]; then icon=""; class="high"
      else icon=""; class="over"
      fi
    fi

    sinkLine="$(get_star_sink_line)"
    sinkName="$(printf "%s" "$sinkLine" | tr -d '│' | sed -E 's/.*\* *[0-9]+\.\s*//; s/\s*\[vol:.*//')"
    [ -z "$sinkName" ] && sinkName="Unknown"

    tooltip="Output: $sinkName\nVolume: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip (muted)"

    tooltipEscaped="$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g')"

    printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
      "$icon" "$pct" "$class" "$tooltipEscaped"
  '';

  # Mic script (default source) – (MANTENUTO INVARIATO)
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
      echo '{"text":" ?","class":"error","tooltip":"No default source"}'
      exit 0
    fi

    muted=0
    if echo "$status" | grep -q 'MUTED'; then muted=1; fi

    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{ if (v+0<0) v=0; if (v>5) v=5; printf "%d", v*100+0.5 }')"

    if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
      icon=""; class="muted"
    else
      icon=""
      if    [ "$pct" -le 30 ]; then class="low"
      elif [ "$pct" -le 70 ]; then class="mid"
      elif [ "$pct" -le 100 ]; then class="high"
      else class="high"
      fi
    fi

    srcLine="$(get_star_source_line)"
    srcName="$(printf "%s" "$srcLine" | tr -d '│' | sed -E 's/.*\* *[0-9]+\.\s*//; s/\s*\[vol:.*//')"
    [ -z "$srcName" ] && srcName="Unknown"

    tooltip="Input: $srcName\nLevel: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip (muted)"

    tooltipEscaped="$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g')"

    printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
      "$icon" "$pct" "$class" "$tooltipEscaped"
  '';

  # Device picker (sink | source) – (MANTENUTO INVARIATO)
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
        # Trim leading space
        sub(/^[[:space:]]*/,"",line)
        mark=""
        if (substr(line,1,1)=="*") { mark="*"; sub(/^\*/,"",line); sub(/^[[:space:]]*/,"",line) }
        # Grab ID (up to first dot)
        id=line
        sub(/\..*/,"",id)
        # Device description (remove leading id + dot + spaces)
        desc=line
        sub(/^[0-9]+\.[[:space:]]*/,"",desc)
        # Cut off [vol: ...] part
        sub(/\[vol:.*$/,"",desc)
        gsub(/[[:space:]]+$/,"",desc)
        print id "\t" mark desc
      }')"

    if [ -z "$entries" ]; then
      command -v notify-send >/dev/null && notify-send "Audio" "No $mode devices parsed"
      exit 0
    fi
    if [ "$(printf "%s" "$entries" | wc -l)" -le 1 ]; then
      command -v notify-send >/dev/null && notify-send "Audio" "Only one $mode device"
      exit 0
    fi
    choice="$(echo "$entries" | rofi -dmenu -p "Select $mode")"
    [ -z "$choice" ] && exit 0
    id="$(printf "%s" "$choice" | cut -f1)"
    wpctl set-default "$id"
    command -v notify-send >/dev/null && notify-send "Audio" "Default $mode -> $id"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  # Slider helper (bar generator) – (MANTENUTO INVARIATO)
  mkSliderBar = pkgs.writeShellScript "gen-bar" ''
    # usage: gen-bar <percent>
    p=$1
    segs=20
    filled=$(( (p*segs)/100 ))
    [ $filled -gt $segs ] && filled=$segs
    bar="$(printf '%*s' "$filled" "" | tr ' ' '#')"
    unfilled=$(( segs - filled ))
    bar="$bar$(printf '%*s' "$unfilled" "" | tr ' ' '-')"
    printf "[%s] %3d%%" "$bar" "$p"
  '';

  # Output volume slider – (MANTENUTO INVARIATO)
  volumeSlider = pkgs.writeShellScript "waybar-volume-slider" ''
    cur=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')
    curPct=$(awk -v v="$cur" 'BEGIN{printf "%d", v*100+0.5}')
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line="* $line"
      else
        line="  $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p 'Output Vol' | sed 's/^* //;s/^  //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$sel%"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  # Mic volume slider – (MANTENUTO INVARIATO)
  micSlider = pkgs.writeShellScript "waybar-mic-slider" ''
    cur=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{print $2}')
    curPct=$(awk -v v="$cur" 'BEGIN{printf "%d", v*100+0.5}')
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line="* $line"
      else
        line="  $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p 'Mic Level' | sed 's/^* //;s/^  //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ "$sel%"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  # Brightness slider – (MANTENUTO INVARIATO)
  brightnessSlider = pkgs.writeShellScript "waybar-brightness-slider" ''
    max=$(brightnessctl m 2>/dev/null)
    curRaw=$(brightnessctl g 2>/dev/null)
    [ -z "$max" ] || [ -z "$curRaw" ] && exit 0
    curPct=$(( curRaw * 100 / max ))
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line="* $line"
      else
        line="  $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p 'Brightness' | sed 's/^* //;s/^  //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    brightnessctl set "$sel%" -q
  '';
in
{
  programs.waybar = {
    enable = true;

    # ------------------------------------------------------------------
    # SETTINGS (Non toccato, solo riorganizzato)
    # ------------------------------------------------------------------
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 4;
        output = [ "eDP-1" "HDMI-A-1" ];

        modules-left   = [ "hyprland/workspaces" "group/sel" ];
        modules-center = [ "clock" ];
        modules-right  = [ "tray" "network" "group/sys" ];

        backlight = {
          format = "{icon} ";
          interval = 2;
          "format-icons" = [ "󰃞" "󰃞" "󰃟" "󰃟" "󰃠" "󰃠" ];
          on-click-middle = "${brightnessSlider}";
          on-scroll-up = "brightnessctl set 5%+ -q";
          on-scroll-down = "brightnessctl set 5%- -q";
        }; 
        cpu = {
          format = " {usage}%";
          interval = 2;
          states = { warning = 70; critical = 90; };
        };

        memory = {
          format = " {percentage}%";
          interval = 5;
          states = { warning = 70; critical = 85; };
        };

        network = {
          interval = 5;
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip = true;
          on-click = "${pkgs.kitty}/bin/kitty -e nmtui";
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

        "group/sel" = {
          orientation = "horizontal";
          modules = [ "custom/volume" "custom/mic" "backlight" ];
        };

        "custom/battery" = {
          interval = 1;
          return-type = "json";
          format = "{}";
          on-click-right = "${pkgs.bash}/bin/bash -c 'if command -v powerprofilesctl >/dev/null; then cur=$(powerprofilesctl get); case $cur in performance) nxt=balanced;; balanced) nxt=power-saver;; power-saver) nxt=performance;; *) nxt=balanced;; esac; powerprofilesctl set \"$nxt\"; fi'";
          exec = ''
            ${pkgs.bash}/bin/bash -c '
            cap_file=/sys/class/power_supply/BAT0/capacity
            status_file=/sys/class/power_supply/BAT0/status
            if [ -r "$cap_file" ]; then cap=$(cat "$cap_file"); else cap="?"; fi
              if [ -r "$status_file" ]; then st=$(cat "$status_file"); else st="Unknown"; fi

                icon=""
                  if [ "$cap" != "?" ]; then
                    [ "$cap" -gt 15 ] && icon=""
                      [ "$cap" -gt 35 ] && icon=""
                        [ "$cap" -gt 60 ] && icon=""
                          [ "$cap" -gt 85 ] && icon=""
                            fi
              case "$st" in
                Charging) icon="" ;;
                Full) icon="" ;;
                esac

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

                          tooltip="Status: $st"
                          [ -n "$profile" ] && tooltip="$tooltip\nProfile: $profile"

                          printf '"'"'{"text":"%s %s%%","tooltip":"%s","class":"%s","alt":"%s"}\n'"'"' \
                            "$icon" "$cap" "$(printf %s "$tooltip" | sed '"'"'s/"/\\"/g'"'"')" "$classes" "$profile"
                            '
                            '';
        };
        "group/sys" = {
          orientation = "horizontal";
          modules = [ "cpu" "memory" "custom/battery" ];
        };
      };
    };
    
    # ------------------------------------------------------------------
    # STYLE (CSS) - Adattato alla nuova palette
    # ------------------------------------------------------------------
    style = ''
      /* Color Definitions */
      @define-color accent  ${c.cyan};        /* TURCHESE/CIANO: Accento principale (digitale, contrasto) */
      @define-color accent2 ${c.yellowBright}; /* ORO VIVACE: Accento secondario (warning/highlight) */
      @define-color fg      ${c.fg};          /* GRIGIO CALDO: Testo principale */
      @define-color fg-alt  ${c.fgAlt};       /* MARRONE GRIGIO: Testo secondario */
      @define-color bg      ${c.bg};          /* NERO/BLU SCURO: Sfondo */
      @define-color bg-alt  ${c.bgAlt};       /* SFUMATURA SCURA: Hover/Sfondi alternativi */
      @define-color border  ${c.border};      /* GRIGIO SCURO: Bordi */
      @define-color warn    ${c.warn};        /* GIALLO/ORO: Warning */
      @define-color error   ${c.error};       /* ROSSO: Errore */
      @define-color ok      ${c.ok};          /* VERDE: OK/Successo */
      @define-color blueIce ${c.blueIce};     /* TURCHESE/CIANO (Alias per accent) */

      /* Trasparenza leggermente ridotta per un effetto "lievemente opaco" */
      @define-color bgTrans rgba(30,32,37,0.92); 

      * {
        font-size: 13px;
        min-height: 0;
        font-family: "IosevkaTerm Nerd Font";
      }

      window#waybar {
        background-color: transparent;
        border-bottom: none;
        color: @fg;
        /* Padding leggermente ridotto per un look più compatto */
        padding: 4px 8px; 
      }

      /* --- Workspaces --- */
      #workspaces {
        padding: 0 4px; /* Rimuovi padding extra per allineamento */
      }
      #workspaces button {
        padding: 1px 10px;
        color: @fg-alt; /* Meno invasivo */
        background: transparent;
        border: none;
        border-radius: 8px;
        margin: 0 1px;
      }
      #workspaces button.focused {
        color: @accent; /* Highlight Ciano/Turchese */
        font-weight: bold;
        background: @bg-alt;
        border-bottom: 2px solid @accent; /* Linea accentata sotto */
        border-radius: 0; /* Rimuovi border-radius per la linea */
      }
      #workspaces button:hover {
        background: @bg-alt;
        color: @fg;
      }
      /* Indicatori speciali (urgent/special) */
      #workspaces button.urgent {
        color: @error;
        background: rgba(212,58,58, 0.2); /* Rosso semi-trasparente */
      }


      /* --- Bubble singoli e gruppi (look più pulito) --- */
      
      /* Bubble Singoli (Clock, Tray, Network) */
      #clock,
      #tray,
      #network {
        background-color: @bg-alt; /* Sfondo alternativo per staccare leggermente */
        color: @fg;
        padding: 1px 10px;
        margin: 0 4px; /* Margine leggermente ridotto */
        border-radius: 16px;
        border: 1px solid @border;
        min-width: 38px;
      }
      #network:hover {
        border: 1px solid @accent; /* Accent Ciano/Turchese su hover */
      }

      /* Bubble Gruppi (System/Audio) */
      #sys,
      #sel {
        background-color: @bg-alt; 
        border-radius: 16px;
        border: 1px solid @border;
        padding: 1px 10px;
        margin: 0 4px;
        min-width: 36px;
      }

      /* Hover sui gruppi */
      #sel:hover,
      #sys:hover {
        border-color: @accent; /* Accent Ciano/Turchese su hover */
      }


      /* === STRUTTURA MODULO PER MODULO PADDING (MANTENUTO) === */
      #cpu { padding: 1px 5px; }
      #custom-battery { padding: 1px 5px; }
      #memory { padding: 1px 5px; }
      #custom-volume{ padding: 1px 5px; }
      #custom-mic{ padding: 1px 5px; }
      #backlight{ padding: 1px 5px; padding-right: 1px; }


      /* --- Stati & colori --- */

      /* Audio */
      #custom-volume.low,
      #custom-mic.low { color: @fg-alt; }

      #custom-volume.mid,
      #custom-mic.mid { color: @fg; border-color: @accent; } /* Testo principale con bordo Ciano */

      #custom-volume.high,
      #custom-mic.high { color: @accent; } /* Accent Ciano/Turchese */

      #custom-volume.over { color: @warn; }

      #custom-volume.muted,
      #custom-mic.muted { color: @error; }

      /* CPU & RAM */
      #cpu { color: @accent2; } /* Oro Vivace */
      #memory { color: @accent2; } /* Oro Vivace */
      #cpu.warning, #memory.warning { color: @warn; }
      #cpu.critical, #memory.critical { color: @error; }

      /* Battery */
      #custom-battery { color: @accent; } /* Accent Ciano/Turchese */
      #custom-battery.charging    { color: @ok; }
      #custom-battery.full        { color: @accent; } 
      #custom-battery.discharging.warning { color: @warn; }
      #custom-battery.discharging.critical { color: @error; }
      #custom-battery.unknown     { color: @fg-alt; }

      /* Network */
      #network { color: @accent2; } /* Oro Vivace */

      /* Tray */
      #tray {
        margin-left: 6px;
        margin-right: 6px;
        padding: 4px;
        background: @bg-alt; /* Usa bg-alt per uniformità */
        border: none;
      }

      /* Clock */
      #clock { color: @accent2; } /* Ora in Oro Vivace */

      /* Backlight */
      #backlight { color: @accent; } /* Accent Ciano/Turchese */
    '';
  };
}
