{ config, pkgs, ... }:
let
  stateDir  = "$HOME/Library/Application Support/macos-rc-watch";
  stateFile = "${stateDir}/known_builds";

  watchScript = pkgs.writeShellApplication {
    name = "macos-rc-watch";
    runtimeInputs = with pkgs; [ jq curl coreutils gnugrep ];
    text = ''
      set -euo pipefail

      mkdir -p "${stateDir}"
      touch "${stateFile}"

      # softwareupdate lists every full installer it has ever offered, not just
      # the latest — filter to macOS 27 so a stray Sequoia/Sonoma re-list never
      # trips a false "new build" notification.
      current="$(softwareupdate --list-full-installers 2>/dev/null \
        | grep -E 'Version: 27(\.|,)' \
        | grep -oE 'Build: [A-Za-z0-9]+' \
        | awk '{print $2}' \
        | sort -u)"

      if [ -z "$current" ]; then
        echo "macos-rc-watch: no macOS 27 full installer listed yet"
        exit 0
      fi

      previous="$(sort -u "${stateFile}")"
      new_builds="$(comm -13 <(printf '%s\n' "$previous") <(printf '%s\n' "$current") | sed '/^$/d')"

      if [ -n "$new_builds" ]; then
        webhook_url="$(cat "${config.sops.secrets."discord_webhook_url".path}")"
        list="$(printf '%s' "$new_builds" | tr '\n' ' ')"
        payload="$(jq -n --arg c "🍎 Nouvel installeur complet macOS 27 disponible — build(s) : $list" '{content: $c}')"
        curl -fsS -X POST -H "Content-Type: application/json" -d "$payload" "$webhook_url" >/dev/null
        echo "macos-rc-watch: notified Discord for build(s) $list"
      else
        echo "macos-rc-watch: no change ($current)"
      fi

      printf '%s\n' "$current" > "${stateFile}"
    '';
  };
in
{
  launchd.agents.macos-rc-watch = {
    enable = true;
    config = {
      ProgramArguments = [ "${watchScript}/bin/macos-rc-watch" ];
      # 3x/day: the catalog scan takes ~10-20s and costs nothing idle, no need
      # for tighter polling to catch a beta drop within a few hours of release.
      StartCalendarInterval = [
        { Hour = 8;  Minute = 0; }
        { Hour = 14; Minute = 0; }
        { Hour = 20; Minute = 0; }
      ];
      StandardOutPath = "/Users/pbear/Library/Logs/macos-rc-watch.log";
      StandardErrorPath = "/Users/pbear/Library/Logs/macos-rc-watch.log";
    };
  };
}
