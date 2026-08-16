{ config, lib, pkgs, ... }:
let
  bypassPath = "${config.home.homeDirectory}/.local/bin/claude-bypass";
  # Stable path to the npm-installed binary (see installClaudeCode activation).
  # Avoids PATH entirely so cmux's own claude wrapper doesn't loop.
  realClaude = "${config.home.homeDirectory}/.npm-global/bin/claude";

  cmuxJsonFile = pkgs.writeText "cmux.json" (builtins.toJSON {
    "$schema"     = "https://raw.githubusercontent.com/manaflow-ai/cmux/main/web/data/cmux.schema.json";
    schemaVersion = 1;
    sidebar = {
      branchLayout                       = "vertical";
      hideAllDetails                     = false;
      openPortLinksInCmuxBrowser         = true;
      openPullRequestLinksInCmuxBrowser  = true;
      showBranchDirectory                = true;
      showCustomMetadata                 = true;
      showLog                            = true;
      showNotificationMessage            = true;
      showPorts                          = true;
      showProgress                       = true;
      showPullRequests                   = true;
      showSSH                            = true;
    };
    notifications = {
      sound = "none";
    };
    automation = {
      # Routes cmux's claude invocations through claude-bypass so
      # --dangerously-skip-permissions is always passed. Without this, cmux's
      # own bash wrapper calls the real binary with only --session-id/--settings,
      # leaving the workspace-trust dialog active every session.
      claudeBinaryPath = bypassPath;
    };
  });
in
{
  # Wrapper invoked by cmux (see automation.claudeBinaryPath). Hardcoded
  # real-binary path avoids resolving through PATH (which would re-enter the
  # cmux wrapper and loop).
  home.file.".local/bin/claude-bypass" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec ${realClaude} --dangerously-skip-permissions "$@"
    '';
  };

  # Nix owns the keys declared above; anything else in cmux.json (settings added
  # by the UI, or new keys from a cmux upgrade) survives activation via a deep
  # merge, Nix side winning on conflicts.
  #
  # Trade-off of merging instead of overwriting: removing a key from this module
  # no longer reverts it on disk — the last written value lingers, since nothing
  # tracks which keys Nix used to own. To actually drop a setting, delete it from
  # the target by hand (or rm cmux.json and re-activate).
  #
  # Arrays are replaced wholesale, not concatenated — jq's `*` only recurses into
  # objects.
  #
  # First-run backup preserves the pre-Nix file (.bak.pre-nix), never overwritten.
  home.activation.cmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/cmux"
    _target="$HOME/.config/cmux/cmux.json"
    _backup="$HOME/.config/cmux/cmux.json.bak.pre-nix"
    if [ -f "$_target" ] && ! [ -f "$_backup" ]; then
      cp "$_target" "$_backup"
    fi
    # Validity is checked up front: a cmux crash mid-write can leave truncated
    # JSON, and merging onto that would abort the whole activation (set -e).
    # Falling back to a clean install is preferable to a failed rebuild.
    if [ -f "$_target" ] && ${pkgs.jq}/bin/jq -e 'type == "object"' "$_target" >/dev/null 2>&1; then
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$_target" ${cmuxJsonFile} > "$_target.tmp"
      mv "$_target.tmp" "$_target"
    else
      install -m 0644 ${cmuxJsonFile} "$_target"
    fi
  '';

  # hasTrustDialogAccepted for $HOME doesn't always persist across runs
  # (suspected race when claude exits while another session writes). Force-set
  # it on each activation so the "Quick safety check" dialog never reappears
  # when launching claude from ~. Safe no-op if .claude.json doesn't exist yet.
  home.activation.claudeTrustHomeFolder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "$HOME/.claude.json" ]; then
      ${pkgs.jq}/bin/jq \
        '.projects["${config.home.homeDirectory}"].hasTrustDialogAccepted = true' \
        "$HOME/.claude.json" > "$HOME/.claude.json.tmp" \
        && mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"
    fi
  '';
}
