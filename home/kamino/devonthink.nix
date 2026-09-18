{ lib, ... }: {
  # Rendu Markdown de DEVONthink. L'app ne lit pas un dossier de config :
  # les deux chemins sont saisis à la main dans
  # Réglages ▸ Files ▸ Markdown ▸ Style Sheet / JavaScript.
  # Ces symlinks fixent donc juste l'emplacement attendu par ces réglages ;
  # changer le chemin ici impose de re-pointer les champs dans l'app.
  home.file = {
    ".config/devonthink/markdown.css".source = ./devonthink/markdown.css;
    ".config/devonthink/markdown.js".source  = ./devonthink/markdown.js;
  };

  # Choix de moteur IA (pas les modèles précis : leurs identifiants changent
  # trop souvent chez OpenRouter pour valoir la peine d'être figés ici).
  # `OpenRouterKey` lui-même n'est PAS gérable par nix : DEVONthink le stocke
  # chiffré dans ce même plist avec une clé liée au Keychain de la machine —
  # un fresh reinstall le rend illisible même si le blob survit (vécu le
  # 18/09/26). La clé en clair va dans Bitwarden, à recoller à la main dans
  # Réglages ▸ AI après chaque reinstall.
  home.activation.devonthinkAIEngine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/defaults write com.devon-technologies.think ChatEngine -int 9
    /usr/bin/defaults write com.devon-technologies.think ChatSummaryEngine -int 9
  '';
}
