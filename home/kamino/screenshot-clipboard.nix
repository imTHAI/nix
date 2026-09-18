{ pkgs, ... }:
let
  watchScript = pkgs.writeShellApplication {
    name = "screenshot-clipboard";
    runtimeInputs = [ pkgs.fswatch ];
    text = ''
      set -euo pipefail

      desktop="$HOME/Desktop"

      # screencapture writes to a hidden dotfile first (e.g. ".Capture
      # d'écran ....png"), then renames it to the final visible name once
      # the write is done — so the final filename only ever gets a Renamed
      # event, never Created. Watching Created alone silently misses every
      # real screenshot (confirmed via `fswatch -x --event-flags`).
      fswatch -0 --event Renamed "$desktop" | while IFS= read -r -d "" file; do
        case "$(basename "$file")" in
          .*) ;; # the hidden intermediate file itself — not the final one
          *.png)
            # screencapture writes the PNG progressively; wait for the size
            # to stop changing before reading it, otherwise a mid-write
            # snapshot can land in the clipboard as a truncated image.
            prev=-1
            while :; do
              size=$(stat -f%z "$file" 2>/dev/null || echo 0)
              if [ "$size" = "$prev" ] && [ "$size" -gt 0 ]; then
                break
              fi
              prev=$size
              sleep 0.2
            done

            # Filenames are locale-dependent ("Screenshot ..." vs "Capture
            # d'écran ..."), so identify screenshots via the Spotlight flag
            # screencapture actually sets on the file instead of the name —
            # this also skips any unrelated PNG dropped onto the Desktop.
            is_capture=$(mdls -raw -name kMDItemIsScreenCapture "$file" 2>/dev/null || echo "")
            if [ "$is_capture" = "1" ]; then
              osascript -e "set the clipboard to (read (POSIX file \"$file\") as «class PNGf»)"
              echo "screenshot-clipboard: copied $file to clipboard"
            fi
            ;;
        esac
      done
    '';
  };
in
{
  launchd.agents.screenshot-clipboard = {
    enable = true;
    config = {
      ProgramArguments = [ "${watchScript}/bin/screenshot-clipboard" ];
      # fswatch blocks forever watching the folder, so this is a persistent
      # watcher (not a cron job): start at login, restart it if it ever dies.
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/pbear/Library/Logs/screenshot-clipboard.log";
      StandardErrorPath = "/Users/pbear/Library/Logs/screenshot-clipboard.log";
    };
  };
}
