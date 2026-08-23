{ ... }: {
  # Rendu Markdown de DEVONthink. L'app ne lit pas un dossier de config :
  # les deux chemins sont saisis à la main dans
  # Réglages ▸ Files ▸ Markdown ▸ Style Sheet / JavaScript.
  # Ces symlinks fixent donc juste l'emplacement attendu par ces réglages ;
  # changer le chemin ici impose de re-pointer les champs dans l'app.
  home.file = {
    ".config/devonthink/markdown.css".source = ./devonthink/markdown.css;
    ".config/devonthink/markdown.js".source  = ./devonthink/markdown.js;
  };
}
