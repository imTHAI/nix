{ pkgs, ... }:
let
  # macOS default screenshot naming is "Screenshot <date> at <time>.png"
  # (`defaults read com.apple.screencapture name/type` unset). If the name
  # prefix or file type is ever customized, the filter below needs to follow.
  watchScript = pkgs.writeShellApplication {
    name = "screenshot-clipboard";
    runtimeInputs = [ pkgs.fswatch ];
    text = ''
      set -euo pipefail

      desktop="$HOME/Desktop"

      # --event Created: only react to new files, not every write while a
      # screenshot is still being flushed — avoids re-copying on later edits.
      fswatch -0 --event Created "$desktop" | while IFS= read -r -d "" file; do
        case "$(basename "$file")" in
          "Screenshot "*.png)
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
            osascript -e "set the clipboard to (read (POSIX file \"$file\") as «class PNGf»)"
            echo "screenshot-clipboard: copied $file to clipboard"
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
