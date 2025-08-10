{ config, lib, pkgs, ... }:

{
  home.activation.createLocalBin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.local/bin
  '';

  home.file."${config.home.homeDirectory}/.local/bin/pomodoro.sh" = {
    text = ''
      #!/usr/bin/env bash
      TIMER_FILE = "/tmp/waybar-pomodoro.timer"
      DURATION = 1500

      if [[ "$1" == start ]]; then
        date +%s > "$TIMER_FILE"
        exit 0
      fi 

      if [[ -f "$TIMER_FILE" ]]; then
        START = $(cat "$TIMER_FILE")
        NOW = $(date +%s)
        REMAIN = $((DURATION - (NOW - START) ))
        if ((REMAIN > 0)); then
          printf '{"text":"%02d:%02d"}\n' $((REMAIN/60)) $((REMAIN%60))
        else 
          printf '{"text":"00:00", "class":"done"}\n'
        fi 
      else 
        echo '{"text":"pomodoro"}'
      fi 
    '';
    executable = true;
  };
}
