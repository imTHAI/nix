{ pkgs, ... }:
let
  copyScript = pkgs.writeShellApplication {
    name = "screenshot-clipboard";
    text = ''
      set -euo pipefail

      desktop="$HOME/Desktop"
      state_dir="$HOME/Library/Application Support/screenshot-clipboard"
      state_file="$state_dir/last-processed-mtime"
      mkdir -p "$state_dir"

      last=0
      [ -f "$state_file" ] && last=$(cat "$state_file")

      # launchd's WatchPaths fires once per directory change but doesn't say
      # which file changed (unlike the previous fswatch-based version), so
      # find the newest screenshot and compare its mtime against the last
      # one we handled. This also survives sleep/wake cleanly: launchd
      # re-arms its own FSEvents subscription on every trigger instead of
      # holding one long-lived stream open, which is what silently died
      # after a sleep cycle in the fswatch version.
      newest=""
      newest_mtime=0
      for file in "$desktop"/*.png; do
        [ -e "$file" ] || continue
        # Filenames are locale-dependent ("Screenshot ..." vs "Capture
        # d'écran ..."), so identify screenshots via the Spotlight flag
        # screencapture actually sets on the file instead of the name —
        # this also skips any unrelated PNG dropped onto the Desktop.
        is_capture=$(mdls -raw -name kMDItemIsScreenCapture "$file" 2>/dev/null || echo "")
        [ "$is_capture" = "1" ] || continue
        mtime=$(stat -f%m "$file")
        if [ "$mtime" -gt "$newest_mtime" ]; then
          newest_mtime=$mtime
          newest=$file
        fi
      done

      if [ -n "$newest" ] && [ "$newest_mtime" -gt "$last" ]; then
        # screencapture writes the PNG progressively; wait for the size to
        # stop changing before reading it, otherwise a mid-write snapshot
        # can land in the clipboard as a truncated image.
        prev=-1
        while :; do
          size=$(stat -f%z "$newest" 2>/dev/null || echo 0)
          if [ "$size" = "$prev" ] && [ "$size" -gt 0 ]; then
            break
          fi
          prev=$size
          sleep 0.2
        done

        osascript -e "set the clipboard to (read (POSIX file \"$newest\") as «class PNGf»)"
        echo "screenshot-clipboard: copied $newest to clipboard"
        echo "$newest_mtime" > "$state_file"
      fi
    '';
  };
in
{
  launchd.agents.screenshot-clipboard = {
    enable = true;
    config = {
      ProgramArguments = [ "${copyScript}/bin/screenshot-clipboard" ];
      WatchPaths = [ "/Users/pbear/Desktop" ];
      StandardOutPath = "/Users/pbear/Library/Logs/screenshot-clipboard.log";
      StandardErrorPath = "/Users/pbear/Library/Logs/screenshot-clipboard.log";
    };
  };
}
