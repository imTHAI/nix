{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [ "**/.claude/settings.local.json" ];
    settings = {
      user = {
        name  = "imTHAI";
        email = "36070606+imTHAI@users.noreply.github.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;
      push.autoSetupRemote = true;  # plus jamais "no upstream branch"
      # No credential helper was ever configured, so HTTPS remotes (git.leet.la
      # projects) had nowhere to cache a PAT: an interactive TTY can still type
      # one when prompted, but a non-interactive process (agent tool calls,
      # scripts) gets "could not read Username" and fails outright. osxkeychain
      # ships with Xcode CLT; after one manual push per machine (see
      # SETUP_NEW_MAC.md), it's silent forever — no secret stored in this repo.
      credential.helper = "osxkeychain";
    };
  };
}
