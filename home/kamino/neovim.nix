{ pkgs, ... }: {

  home.packages = with pkgs; [
    ripgrep       # telescope file search
    fd            # telescope file finder
    lazygit       # lazygit.nvim integration
    stylua        # lua formatter
    lua-language-server
  ];

  # Symlink config files individually so ~/.config/nvim/ stays writable
  # (lazy-lock.json needs to be written there by lazy.nvim)
  xdg.configFile."nvim/init.lua".source    = ./nvim/init.lua;
  xdg.configFile."nvim/lua".source         = ./nvim/lua;
}
