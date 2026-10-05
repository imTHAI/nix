{ config, pkgs, inputs, ... }:
let
  net = (import "${inputs.nix-private}/hosts.nix").hothNet;
in {
  # FreeRDP launcher for hoth's krdp server (Plasma session sharing). Started
  # under GNOME Remote Login, whose server redirection broke Windows App; krdp
  # has no redirection, so Windows App may work again, but this stays as the
  # known-good client.
  # Without OpenH264, FreeRDP falls back to FFmpeg's H.264 decoder. krdp's
  # software encoder (libx264, no GPU in the VM) tags its stream level 6.2,
  # which OpenH264 rejects as a bitstream error: the keyframe is dropped and
  # the window stays white. https://bugs.kde.org/show_bug.cgi?id=526199
  home.packages = [ (pkgs.freerdp.override { openh264 = null; }) ];

  sops.secrets."hoth_rdp_password" = {
    sopsFile = ../../secrets/kamino/hoth.yaml;
    key = "rdp_password";
  };

  # /args-from:stdin cannot be mixed with other CLI args, so every argument goes
  # through the pipe; keeps the password out of the process list.
  # /cert:tofu pins hoth's self-signed cert on first connect.
  # krdp streams hoth's real output at a fixed size (2560x1440, set with
  # kscreen-doctor on hoth) and ignores client resize requests, so no
  # /dynamic-resolution. A full 2560x1440 window cannot fit under the macOS
  # menu bar on a 2560x1440 display: open a 16:9 window slightly smaller and
  # let /smart-sizing scale the picture to whatever size the window gets.
  # FreeRDP's fullscreen is not the native macOS one (no traffic lights on
  # hover); Ctrl+Option+Return toggles it.
  programs.zsh.initContent = ''
    hoth-rdp() {
      {
        printf '%s\n' /v:${net.address4} /u:pbear /cert:tofu /size:2560x1440 /smart-sizing:2240x1260 +clipboard
        printf '/p:%s\n' "$(< ${config.sops.secrets."hoth_rdp_password".path})"
      } | sdl-freerdp /args-from:stdin &>/dev/null &!
    }
  '';
}
