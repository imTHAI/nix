{ config, ... }:
let
  haDir = "${config.home.homeDirectory}/.config/homeassistant";
in {
  # Home Assistant (HA OS VM on coruscant) API access: long-lived access token
  # plus base URL, consumed by scripts and Claude Code via
  #   curl -H "Authorization: Bearer $(cat ~/.config/homeassistant/token)" "$(cat ~/.config/homeassistant/url)/api/"
  # The URL is kept in sops too: it is a LAN address, not worth a public commit.
  # sops-nix places symlinks at these paths pointing to the decrypted files, so
  # nothing plaintext lives in the repo or the store.
  sops.secrets."homeassistant_token" = {
    sopsFile = ../../secrets/kamino/homeassistant.yaml;
    key = "token";
    path = "${haDir}/token";
  };
  sops.secrets."homeassistant_url" = {
    sopsFile = ../../secrets/kamino/homeassistant.yaml;
    key = "url";
    path = "${haDir}/url";
  };
}
