{ ... }: {
  programs.zsh = {
    profileExtra = ''
      typeset -U path
      path=(/etc/profiles/per-user/$USER/bin /run/current-system/sw/bin $HOME/Applications/bin /opt/homebrew/bin /opt/homebrew/sbin $HOME/.local/bin $path)
    '';
    history.path = "$HOME/.zsh_history";
    shellAliases = {
      # Route all manual `claude` invocations through claude-bypass so
      # --dangerously-skip-permissions is always injected, regardless of
      # whether the session was started by cmux or typed directly.
      claude  = "$HOME/.local/bin/claude-bypass";
      nixup   = "_nixupdate kamino darwin-rebuild";
      nixrb   = "_nixrebuild kamino darwin-rebuild";
      # Pas de GC automatique configurée (nix.gc retiré lors de la migration
      # Determinate, jamais restauré) — -d supprime aussi les vieilles
      # générations système/darwin-rebuild, pas seulement le profil user.
      nixgc   = "sudo nix-collect-garbage -d && sudo nix store optimise";
      # nix flake archive prefetches inputs as the user: the sudo'd rebuild would
      # otherwise fetch git+ssh inputs (nix-private) as root, whose ssh has no key.
      nixpull = "cd ~/.config/nix && git pull && nix flake archive && sudo darwin-rebuild switch --flake ~/.config/nix#kamino";
      cdd        = "cd $HOME/Downloads";
      cdm        = "cd $HOME/media";
      cddu       = "cd $HOME/downloads_unraid";
      reloaddns  = "dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
      macos_sign = "xattr -cr";
      copyssh    = "pbcopy < $HOME/.ssh/id_ed25519.pub";
      shrug      = "echo '¯\\_(ツ)_/¯' | pbcopy";
      lldot      = "ls -ld .*(D)";
      dl         = "aria2c -x4 --dir=$HOME/Downloads";
      ogg2m4a    = "audio_convert ogg";
      flac2m4a   = "audio_convert flac";
      sync_photoslib         = "rsync -avh --progress --exclude='.DS_Store' --delete $HOME/Pictures/Photos\\ Library.photoslibrary coruscant:/mnt/user/backups/";
      sync_photoslib_archive = "rsync -avh --progress --exclude='.DS_Store' --delete /Volumes/TB_500Go/Images/Archives.photoslibrary coruscant:/mnt/user/backups/";
      sync_calibre      = "rsync -avh --progress --exclude='.DS_Store' --delete /Volumes/TB_500Go/Librairie\\ Calibre coruscant:/mnt/user/media/books/";
      sync_calibre_down = "rsync -avh --progress --exclude='.DS_Store' --delete coruscant:/mnt/user/media/books/Librairie\\ Calibre /Volumes/TB_500Go/";
      sync_bin       = "rsync -avh --progress --exclude='.DS_Store' --delete $HOME/Applications/bin coruscant:/mnt/user/backups/";
      sync_homedir   = "rsync -vah -e ssh --exclude=\".git\" --exclude=\".venv\" --exclude=\".DS_Store\" --exclude=\"Survivalisme\" --exclude=\"Family_Media_Library\" --delete coruscant:/mnt/user/homedir-pbear/ \"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups/homedir-pbear/\"";
    };
    initContent = ''
      if command -v vivid >/dev/null; then
        export LS_COLORS="$(vivid generate molokai)"
      fi
      audio_convert() {
        local ext=$1
        find . -name "*.$ext" -type f -exec sh -c '
          mkdir -p output
          basename_file=$(basename "$1" .'"$ext"')
          clean_name=$(echo "$basename_file" | sed "s/^[0-9]\{1,2\}\. //")
          ffmpeg -i "$1" -vn -c:a alac -f mp4 "output/''${clean_name}.m4a"
        ' _ {} \;
      }
      heic2jpg() {
        local input_path="$(realpath "$1")"
        local output_path="''${input_path%.*}.jpg"
        sips -s format jpeg "$input_path" --out "$output_path"
      }
    '';
  };
}
