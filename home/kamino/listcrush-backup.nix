{ pkgs, ... }:
let
  projectDir = "/Users/pbear/Projects/listcrush";
  # SMB share on unraid, mounted by the mount-smb agent in apps.nix. Deliberately
  # not a local path: a dump sitting on the same disk as nothing else protects
  # against exactly one failure mode (a bad DELETE) and none of the others.
  destDir = "/Users/pbear/homedir-pbear/backups/listcrush";
  keepDays = 30;

  backupScript = pkgs.writeShellApplication {
    name = "listcrush-backup";
    runtimeInputs = with pkgs; [ supabase-cli gzip coreutils findutils ];
    text = ''
      set -euo pipefail

      DEST="${destDir}"
      STAMP="$(date +%Y-%m-%d)"

      # The share is remounted every 30 min by the mount-smb agent, but a dump
      # written into an empty mountpoint would land on the local disk and look
      # like a success. Refuse rather than lie about where the backup went.
      if ! /sbin/mount | grep -q "on /Users/pbear/homedir-pbear "; then
        echo "listcrush-backup: homedir-pbear is not mounted, aborting" >&2
        exit 1
      fi

      mkdir -p "$DEST"

      # The CLI keeps its Management API token in the login keychain, which a
      # user LaunchAgent can read — so no second copy has to live in sops. It
      # is stored through go-keyring, which base64-wraps the value behind a
      # marker prefix; handing the raw item to the CLI gets "Invalid access
      # token format". Strip the prefix and decode.
      raw="$(/usr/bin/security find-generic-password -s 'Supabase CLI' -a supabase -w)"
      SUPABASE_ACCESS_TOKEN="$(printf '%s' "''${raw#go-keyring-base64:}" | base64 -d)"
      export SUPABASE_ACCESS_TOKEN

      case "$SUPABASE_ACCESS_TOKEN" in
        sbp_*) ;;
        # Guards against the keyring format changing under us: without this the
        # CLI would fail three times and the run would look like a network
        # problem rather than a credential one.
        *) echo "listcrush-backup: keychain did not yield an sbp_ token" >&2; exit 1 ;;
      esac

      # --linked resolves the project ref from supabase/.temp, so the dump has
      # to run from inside the repo.
      cd "${projectDir}"

      # Three dumps, per Supabase's own restore procedure: roles and schema are
      # nearly free, and while the schema is reproducible from the migrations in
      # git, that only holds as long as nothing was ever applied straight from
      # the dashboard. The schema dump is what catches that drift.
      for part in roles schema data; do
        case "$part" in
          roles)  flag="--role-only"   ;;
          schema) flag=""              ;;
          data)   flag="--data-only"   ;;
        esac

        tmp="$DEST/.$STAMP-$part.sql.partial"
        out="$DEST/$STAMP-$part.sql.gz"

        # Dump to a temp name and only move it into place once gzip succeeded —
        # an interrupted run must never truncate the previous day's good file.
        # shellcheck disable=SC2086
        supabase db dump --linked $flag -f "$tmp"
        gzip -c "$tmp" > "$out.partial"
        mv "$out.partial" "$out"
        rm -f "$tmp"
      done

      # Retention. -mtime is on the file, not the name, so a day the job didn't
      # run simply leaves an older file in place rather than shifting the window.
      find "$DEST" -name '*.sql.gz' -type f -mtime +${toString keepDays} -delete
      find "$DEST" -name '*.partial' -type f -mtime +1 -delete

      echo "listcrush-backup: $STAMP written to $DEST"
      du -sh "$DEST"
    '';
  };
in {
  launchd.agents.listcrush-backup = {
    enable = true;
    config = {
      ProgramArguments = [ "${backupScript}/bin/listcrush-backup" ];
      # 04:30 daily. Not RunAtLoad: every login would spend a dump on data that
      # almost certainly hasn't changed since the last one.
      StartCalendarInterval = [{ Hour = 4; Minute = 30; }];
      StandardOutPath = "/Users/pbear/Library/Logs/listcrush-backup.log";
      StandardErrorPath = "/Users/pbear/Library/Logs/listcrush-backup.log";
    };
  };
}
