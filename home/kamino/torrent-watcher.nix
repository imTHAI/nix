{ config, pkgs, ... }:
{
  # Was a hand-written plist in ~/Library/LaunchAgents, invisible to the flake
  # and lost on every reformat. Migrated here so a rebuild recreates it.
  # The script itself stays outside the repo (~/Applications/bin, synced via
  # iCloud per SETUP_NEW_MAC.md) — it predates this flake and isn't tracked
  # in git. uv resolves its PEP 723 inline deps (watchdog) at run time, so no
  # Nix-level Python derivation is needed here.
  launchd.agents.torrentwatcher = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.uv}/bin/uv"
        "run"
        "${config.home.homeDirectory}/Applications/bin/torrent_watcher.py"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables = {
        PYTHONUNBUFFERED = "1";
      };
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/com.user.torrentwatcher.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/com.user.torrentwatcher.err.log";
    };
  };
}
