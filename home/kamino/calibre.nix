{ lib, ... }:
# Calibre config bootstrap — copies preference files on fresh install only.
# Files are NOT symlinked (Calibre writes to them at runtime; read-only Nix
# store symlinks would cause crashes). On an existing install, Calibre manages
# the files itself; re-run `nixrb` won't overwrite your live settings.
#
# To update the snapshot after tweaking Calibre:
#   cp ~/Library/Preferences/calibre/tweaks.json          ~/.config/nix/home/kamino/calibre/
#   cp ~/Library/Preferences/calibre/save_to_disk.py.json ~/.config/nix/home/kamino/calibre/
#   cp ~/Library/Preferences/calibre/gui.json             ~/.config/nix/home/kamino/calibre/
#   cp ~/Library/Preferences/calibre/gui.py.json          ~/.config/nix/home/kamino/calibre/
#   cp ~/Library/Preferences/calibre/global.py.json       ~/.config/nix/home/kamino/calibre/
#   # Then commit + push.
#
# Plugins (manually install via Calibre → Préférences → Plugins after restore):
#   - Reading List
#   - Kindle Collections
# The .zip files are kept in calibre/plugins/ as reference.
#
# Note: global.py.json contains machine-specific paths (library_path,
# database_path). After a reformat, Calibre will prompt to locate the library —
# point it to /Volumes/TB_500Go/Librairie Calibre as usual.
{
  home.activation.calibreConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _prefs="$HOME/Library/Preferences/calibre"
    mkdir -p "$_prefs/plugins"

    _copy_if_missing() {
      local src="$1" dst="$2"
      [ -f "$dst" ] && return
      cp "$src" "$dst"
      chmod 644 "$dst"
    }

    _copy_if_missing ${./calibre/tweaks.json}          "$_prefs/tweaks.json"
    _copy_if_missing ${./calibre/save_to_disk.py.json} "$_prefs/save_to_disk.py.json"
    _copy_if_missing ${./calibre/global.py.json}       "$_prefs/global.py.json"
    _copy_if_missing ${./calibre/gui.json}             "$_prefs/gui.json"
    _copy_if_missing ${./calibre/gui.py.json}          "$_prefs/gui.py.json"

    _copy_if_missing "${./calibre/plugins}/Reading List.zip"       "$_prefs/plugins/Reading List.zip"
    _copy_if_missing "${./calibre/plugins}/Reading List.json"      "$_prefs/plugins/Reading List.json"
    _copy_if_missing "${./calibre/plugins}/Kindle Collections.zip" "$_prefs/plugins/Kindle Collections.zip"
  '';
}
