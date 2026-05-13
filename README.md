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
| `tatooine` | Laptop Windows (NixOS WSL) | NixOS WSL | ⏳ Bloqué Zscaler |
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
│   ├── kamino/default.nix  # system config macOS — packages, casks, colima
│   ├── jakku/
│   │   ├── default.nix     # system config NixOS — réseau, docker, openssh
│   │   └── hardware.nix    # généré par nixos-generate-config
│   └── tatooine/default.nix # system config NixOS WSL + cert Zscaler
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
│   │   ├── default.nix     # identity + imports
│   │   ├── shell.nix       # aliases macOS, fonctions audio/heic2jpg
│   │   ├── apps.nix        # ghostty, mc, nano, gh-dash, packages
│   │   ├── packages.nix    # packages home kamino
│   │   └── firefox.nix     # profil Firefox + extensions + settings
│   ├── jakku/              # NixOS VM
│   │   ├── default.nix
│   │   └── packages.nix
│   └── tatooine/           # NixOS WSL
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

```bash
git clone git@github.com:imTHAI/nix.git ~/.config/nix
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix#<nom>
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
