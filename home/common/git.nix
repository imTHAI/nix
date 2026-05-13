{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name  = "imTHAI";
        email = "36070606+imTHAI@users.noreply.github.com";
      };
      push.autoSetupRemote = true;  # plus jamais "no upstream branch"
    };
  };
}
