{ ... }: {
  programs.zsh = {
    profileExtra = ''
      typeset -U path
      path=(/etc/profiles/per-user/$USER/bin /run/current-system/sw/bin $HOME/Applications/bin /opt/homebrew/bin /opt/homebrew/sbin $path)
    '';
    history.path = "$HOME/.zsh_history";
    shellAliases = {
      nixup   = "_nixupdate kamino darwin-rebuild";
      nixrb   = "_nixrebuild kamino darwin-rebuild";
      nixpull = "cd ~/.config/nix && git pull && sudo darwin-rebuild switch --flake ~/.config/nix#kamino";
      reloaddns  = "dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
      macos_sign = "xattr -cr";
      copyssh    = "pbcopy < $HOME/.ssh/id_ed25519.pub";
      shrug      = "echo '¯\\_(ツ)_/¯' | pbcopy";
      lldot      = "ls -ld .*(D)";
      dl         = "aria2c -x4 --dir=$HOME/Downloads";
      ogg2m4a    = "audio_convert ogg";
      flac2m4a   = "audio_convert flac";
      sync_photoslib = "rsyncy -vah --exclude='.DS_Store' --delete $HOME/Pictures/Photos\\ Library.photoslibrary coruscant:/mnt/user/backups/";
      sync_calibre   = "rsyncy -vah --exclude='.DS_Store' --delete /Volumes/TB_500Go/Librairie\\ Calibre coruscant:/mnt/user/media/books/";
      sync_bin       = "rsyncy -avh --exclude='.DS_Store' --delete $HOME/Applications/bin coruscant:/mnt/user/backups/";
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
