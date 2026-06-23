{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [ "**/.claude/settings.local.json" ];
    settings = {
      user = {
        name  = "imTHAI";
        email = "36070606+imTHAI@users.noreply.github.com";
      };
      push.autoSetupRemote = true;  # plus jamais "no upstream branch"
    };
  };
}
