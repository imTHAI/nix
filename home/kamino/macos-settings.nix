{ ... }: {
  # User-scope macOS settings (Finder, Dock, trackpad, keyboard, menu bar...).
  # Captured via `nix run github:sushydev/nix-plist-manager#current -- <file> --scope user`
  # and re-run the same way after a manual System Settings change to update it.
  programs.nix-plist-manager.enable = true;
  programs.nix-plist-manager.options = import ./mac-settings-user.nix;
}
