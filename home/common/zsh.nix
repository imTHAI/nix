{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    history = {
      size   = 10000;
      save   = 10000;
      share  = true;
      append = true;
    };
    plugins = [
      { name = "zsh-autosuggestions";     src = pkgs.zsh-autosuggestions;     file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh"; }
      { name = "zsh-syntax-highlighting"; src = pkgs.zsh-syntax-highlighting; file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; }
    ];
    initContent = ''
      export LANG="fr_FR.UTF-8"
      export LC_ALL="fr_FR.UTF-8"
      export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
      autoload -Uz up-line-or-beginning-search
      autoload -Uz down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      bindkey '^[[B' down-line-or-beginning-search
      autoload -Uz compinit && compinit
      zstyle ':completion:*' menu select
      gitsync() {
        local branch=$(git rev-parse --abbrev-ref HEAD)
        echo "🚀 Forçage du local vers origin/$branch..."
        git add -A
        git commit -m "sync: manual force"
        git push origin "$branch" --force
      }
      gitrestore() {
        local branch=$(git rev-parse --abbrev-ref HEAD)
        echo "📥 Récupération forcée de origin/$branch..."
        git fetch origin
        git reset --hard origin/"$branch"
        git clean -fd
      }
      # Rebuild Nix avec prompt de commit
      # Usage: _nixrebuild <host> <darwin-rebuild|nixos-rebuild>
      _nixrebuild() {
        local host=$1
        local cmd=$2
        cd ~/.config/nix || return 1
        git add -A
        local msg
        read "msg?Message de commit [chore: rebuild]: "
        : ''${msg:=chore: rebuild}
        git commit -m "$msg" || return 1
        sudo $cmd switch --flake ~/.config/nix#$host || return 1
        git push
      }
      # Update flake puis rebuild
      _nixupdate() {
        local host=$1
        local cmd=$2
        cd ~/.config/nix || return 1
        nix flake update
        git add flake.lock
        git commit -m "chore: flake update"
        sudo $cmd switch --flake ~/.config/nix#$host || return 1
        git push
      }
    '';
    shellAliases = {
      reloadshell = "source $HOME/.zshrc";
      mkpy        = "nix flake init --template ~/.config/nix#python && direnv allow";
      cdd         = "cd $HOME/Downloads";
      cdm         = "cd $HOME/media";
      cddu        = "cd $HOME/downloads_unraid";
      ytdl        = ''yt-dlp -f "bv*[height=1080][ext=mp4][vcodec^=avc1]+ba[ext=m4a]/bestvideo[height=1080][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4]"'';
    };
  };
}
