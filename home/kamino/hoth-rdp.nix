{ config, pkgs, inputs, ... }:
let
  net = (import "${inputs.nix-private}/hosts.nix").hothNet;
in {
  # FreeRDP instead of Windows App: hoth runs GNOME Remote Login, whose server
  # redirection hands the client one-time credentials. Windows App (macOS)
  # ignores them and resends the saved ones, so NTLM fails after the redirect.
  home.packages = [ pkgs.freerdp ];

  sops.secrets."hoth_rdp_password" = {
    sopsFile = ../../secrets/kamino/hoth.yaml;
    key = "rdp_password";
  };

  # /args-from:stdin cannot be mixed with other CLI args, so every argument goes
  # through the pipe; keeps the password out of the process list.
  # /cert:tofu pins hoth's self-signed cert on first connect.
  programs.zsh.initContent = ''
    hoth-rdp() {
      {
        printf '%s\n' /v:${net.address4} /u:pbear /cert:tofu /dynamic-resolution /size:1920x1200 +clipboard
        printf '/p:%s\n' "$(< ${config.sops.secrets."hoth_rdp_password".path})"
      } | sdl-freerdp /args-from:stdin &>/dev/null &!
    }
  '';
}
