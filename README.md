# Nix Config

Repo privé : `github.com/imTHAI/nix`  
Config locale : `~/.config/nix/`  
Approche : **Nix Flakes + nix-darwin + NixOS + Home Manager**

---

## Parc machine

| Nom | Machine | OS | Statut |
|---|---|---|---|
| `kamino` | Mac Mini M1 | macOS | ✅ Opérationnel |
| `jakku` | VM NixOS sur Unraid | NixOS 25.11 | ✅ Opérationnel |
| _(à définir)_ | Mac Mini M5 (futur) | macOS | ⏳ |

---

## Structure des fichiers

```
~/.config/nix/
├── flake.nix               # orchestrateur — inputs + outputs
├── flake.lock              # versions verrouillées — toujours committer
├── vars.nix                # username, email — source de vérité unique
├── .sops.yaml              # clés publiques age par machine
│
├── system/
│   ├── common.nix          # commun à toutes les machines (nix settings, NUR overlay)
│   └── darwin.nix          # commun à tous les Macs (dock, finder, homebrew, GC)
│
├── hosts/
│   ├── kamino/default.nix  # system config macOS — packages, casks, brews (rtk), colima
│   └── jakku/
│       ├── default.nix     # system config NixOS — réseau, docker, openssh
│       └── hardware.nix    # généré par nixos-generate-config
│
├── home/
│   ├── common/             # partagé toutes machines
│   │   ├── packages.nix    # CLI tools (neovim, rsync, gh, sops, age...)
│   │   ├── git.nix
│   │   ├── ssh.nix
│   │   ├── zsh.nix         # historique, plugins, fonctions _nixrebuild
│   │   ├── starship.nix
│   │   ├── starship.toml
│   │   └── direnv.nix
│   ├── kamino/             # macOS uniquement
│   │   ├── default.nix     # identity + imports + activation Library/Logs/SopsNix
│   │   ├── shell.nix       # aliases macOS, fonctions audio/heic2jpg
│   │   ├── apps.nix        # ghostty, mc, nano, gh-dash, packages
│   │   ├── packages.nix    # packages home kamino
│   │   ├── firefox.nix     # profil Firefox + extensions + settings
│   │   ├── claude.nix      # settings.json (hooks rtk + nix), CLAUDE.md, RTK.md, sops inject
│   │   ├── cmux.nix        # claude-bypass wrapper, cmux.json, patch hasTrustDialogAccepted
│   │   └── claude/         # assets sourcés (CLAUDE.md, RTK.md, rules/)
│   └── jakku/              # NixOS VM
│       ├── default.nix
│       └── packages.nix
│
├── secrets/
│   ├── kamino/             # secrets chiffrés age pour kamino
│   └── jakku/              # secrets chiffrés age pour jakku
│
└── templates/
    └── python/             # nix flake init --template ~/.config/nix#python
        ├── flake.nix       # Python + uv + ruff + pyright
        └── .envrc
```

---

## Séparation des responsabilités

```
system/         → nix settings, nixpkgs, overlays
system/darwin   → macOS (dock, finder, homebrew, GC, Spotlight)
hosts/<machine> → config spécifique à la machine
home/common/    → config utilisateur partagée
home/<machine>/ → config utilisateur spécifique
secrets/        → secrets chiffrés (sops + age)
```

### Règle packages macOS

```
1. nixpkgs      → CLI tools, fonts, outils dev (déclaratif, reproductible)
2. homebrew     → apps GUI macOS (VSCode, Firefox, Discord...) — auto-update natif
3. manuel       → nightly, beta, non packagé
```

Les apps GUI sensibles (navigateurs, Discord, Bitwarden) restent dans brew pour
recevoir les mises à jour de sécurité immédiatement sans attendre nixpkgs.

---

## Workflow quotidien

```bash
nixrb   # git add -A + prompt commit + rebuild + git push
nixup   # nix flake update + rebuild + git push
nixpull # git pull + rebuild (sync depuis GitHub)
```

### Ajouter un nouveau Mac

Voir [`SETUP_NEW_MAC.md`](SETUP_NEW_MAC.md) pour la procédure complète
(install Nix, clone, restore age key, rebuild, cmux DMG, login Claude…).

```bash
git clone git@github.com:imTHAI/nix.git ~/.config/nix
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix#<nom>
```

### Réinstall jakku (NixOS VM Unraid)

```bash
# 1. Installer NixOS dans la VM, créer user pbear, activer flakes
# 2. Sur kamino, copier la config sur jakku :
ssh pbear@jakku 'sudo nix-shell -p git --run "git clone https://github.com/imTHAI/nix.git /etc/nixos-flake"'

# 3. Restaurer ~/.config/sops/age/keys.txt depuis Bitwarden
ssh pbear@jakku 'mkdir -p ~/.config/sops/age'
scp ~/.config/sops/age/keys.txt pbear@jakku:~/.config/sops/age/keys.txt  # ou paste manuel

# 4. Premier rebuild
ssh pbear@jakku 'sudo nixos-rebuild switch --flake /etc/nixos-flake#jakku'

# 5. Clé SSH dédiée si besoin (pour git push depuis jakku)
ssh pbear@jakku 'ssh-keygen -t ed25519 -C "pbear@jakku"'
```

### Nouveau projet Python

```bash
mkdir ~/Projects/mon-projet && cd ~/Projects/mon-projet
mkpy   # nix flake init --template ~/.config/nix#python + direnv allow
```

---

## Secrets (sops + age)

La clé privée age de chaque machine vit dans `~/.config/sops/age/keys.txt`
(hors repo, jamais commitée). Les clés publiques sont dans `.sops.yaml`.

```bash
sops secrets/kamino/secrets.yaml   # créer/éditer un secret
sops -d secrets/kamino/secrets.yaml # déchiffrer
```

**Important** : sauvegarder `~/.config/sops/age/keys.txt` dans Bitwarden —
sans elle les secrets deviennent irrécupérables après un reformatage.

---

## Inputs flake

| Input | Rôle |
|---|---|
| `nixpkgs` | packages nixpkgs-unstable |
| `nix-darwin` | modules macOS |
| `mac-app-util` | symlinks ~/Applications pour Spotlight/Alfred |
| `nix-homebrew` | homebrew déclaratif |
| `home-manager` | config utilisateur |
| `sops-nix` | déchiffrement secrets au boot |
| `nixos-wsl` | support NixOS sur WSL2 |
| `nur` | extensions Firefox (Bitwarden, SponsorBlock) |
