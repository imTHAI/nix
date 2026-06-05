# Préférences globales

> Ce fichier est géré par Nix home-manager (kamino).
> Ne jamais éditer les fichiers `~/.claude/` directement — ils sont tous gérés par Nix.
>
> | Fichier | Source Nix |
> |---------|-----------|
> | `~/.claude/CLAUDE.md` | `home/kamino/claude/CLAUDE.md` (symlink) |
> | `~/.claude/settings.json` | `home/kamino/claude.nix` (généré à l'activation) |
> | `~/.claude/settings.local.json` | `home/kamino/claude/settings.local.json` (symlink) |
> | `~/.claude/RTK.md` | `home/kamino/claude/RTK.md` (symlink) |
> | `~/.claude/rules/python.md` | `home/kamino/claude/rules/python.md` (symlink) |
> | `~/.claude/statusline-command.sh` | `home/kamino/claude/statusline-command.sh` (symlink) |
> | `~/.claude/sounds/*.mp3` | `home/kamino/claude/sounds/` (symlinks) |
>
> Workflow : éditer la source Nix → `nixrb` → push GitHub.


## Langue
Réponds toujours en français, sauf si je t'écris dans une autre langue.

## Ton et style de réponse
- Sois concis et direct — pas de longues explications non demandées
- Pas d'emojis dans les réponses texte
- Une phrase de mise à jour suffit ; n'annonce pas ce que tu vas faire avant de le faire

## Code
- Commente le code en détail : explique le WHY, les invariants non-obvieux, les workarounds
- Pas de commentaires inutiles qui répètent ce que le nom de la variable dit déjà
- Tous les commentaires dans le code sont en anglais, quelle que soit la langue du projet
- Les commentaires sont écrits comme des notes techniques entre développeurs — jamais comme une IA qui guide l'utilisateur ("here we need to...", "this is where we handle...", "note that...")
- Langages principaux : Python, Nix/NixOS, TypeScript/JS

## Git
- Format des commits : Gitmoji (`✨ feat`, `🐛 fix`, `♻️ refactor`, `🔧 chore`, etc.)
- Ne committe jamais sans que je le demande explicitement
- Ne pousse jamais sans confirmation

## Nix macOS — règles de placement des packages

- CLI tools → `home/kamino/packages.nix` (`home.packages`)
- Apps GUI nixpkgs (ex: `ghostty-bin`, `obsidian`) → `hosts/kamino/default.nix` (`environment.systemPackages`)
  - Raison : `mac-app-util` crée les symlinks dans `/Applications` → visible par Alfred/Spotlight
  - `home.packages` installe dans `~/Applications/Home Manager Apps/` → **non indexé par Alfred**
- Apps GUI sans nixpkgs → `homebrew.casks` dans `hosts/kamino/default.nix`
- Pour vérifier si un package supporte aarch64-darwin : `nix eval nixpkgs#<pkg>.meta.platforms`

## Setup machines
- **kamino** : macOS, nix-darwin + home-manager
- **scarif** : Arch Linux, home-manager standalone (pas NixOS)
- **jakku** : NixOS (VM)
- Config Nix centrale : `~/.config/nix/` (flake multi-host, noms Star Wars)
- **sops-nix est déjà configuré** dans le flake — ne pas redemander
- **age key** déjà présente sur kamino

## Actions risquées
- Demande confirmation avant toute action irréversible : suppression de fichiers/branches, push, reset --hard, drop de base de données
- Pour les éditions de fichiers et actions locales réversibles : agis librement sans demander
- **Suppression de fichiers** : utiliser `trash` (commande native macOS, `/usr/bin/trash`) au lieu de `rm -rf` — récupérable depuis la Corbeille. Réserver `rm -rf` aux cas où le fichier doit être détruit définitivement et de manière confirmée (caches, dossiers temporaires)
