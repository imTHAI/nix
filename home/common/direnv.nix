{ ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # suppress the verbose "export +AR +AS..." lines on shell load
    stdlib = ''
      export DIRENV_LOG_FORMAT=""
    '';
  };
}
