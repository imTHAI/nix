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
    };
  };
}
