# Setup nouveau Mac

Temps estimé : 30-45 min (hors téléchargements)

---

## 1. Pré-requis Apple

```bash
# Accepter les outils Xcode (requis pour git, etc.)
xcode-select --install
```

---

## 2. Installer Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Ferme et rouvre le terminal après l'install.

---

## 3. Cloner la config

```bash
mkdir -p ~/.config
git clone git@github.com:imTHAI/nix.git ~/.config/nix
```

> Si la clé SSH n'est pas encore configurée, utilise HTTPS :
> ```bash
> git clone https://github.com/imTHAI/nix.git ~/.config/nix
> ```

---

## 4. Premier build

```bash
# Pour kamino (Mac Mini M1) :
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix#kamino

# Pour un nouveau Mac (nouveau nom à créer dans hosts/) :
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix#<nom>
```

> La première fois prend plus longtemps — tout est téléchargé depuis cache.nixos.org.

Le rebuild remet automatiquement en place :
- Système : packages CLI, dock, Finder, GC, homebrew (casks + brews dont `rtk`)
- User : zsh + plugins, git, ssh, starship, direnv, ghostty, gh-dash
- Firefox : profil + extensions (Bitwarden, SponsorBlock) via NUR
- Claude Code : `~/.claude/settings.json` (hooks rtk + nix, MCP context7 via sops),
  `CLAUDE.md`, `RTK.md`, `rules/`, plus `~/.claude.json` patché (`hasTrustDialogAccepted: true` pour `$HOME`)
- cmux : `~/.config/cmux/cmux.json` Nix-géré (sidebar + `claudeBinaryPath` →
  `~/.local/bin/claude-bypass` qui ajoute `--dangerously-skip-permissions`)
- sops : décryptage automatique au boot via LaunchAgent (logs dans `~/Library/Logs/SopsNix/`)

---

## 5. Configurer la clé SSH

```bash
# Générer une nouvelle clé
ssh-keygen -t ed25519 -C "pbear@<nom-machine>"

# Afficher la clé publique à ajouter sur GitHub
cat ~/.ssh/id_ed25519.pub
```

Ajouter sur **github.com → Settings → SSH Keys**.

---

## 6. Restaurer la clé age (sops)

Récupère `keys.txt` depuis Bitwarden et place-la :

```bash
mkdir -p ~/.config/sops/age
# colle le contenu depuis Bitwarden :
nano ~/.config/sops/age/keys.txt
```

Vérifie que sops fonctionne :
```bash
sops -d ~/.config/nix/secrets/kamino/secrets.yaml
```

---

## 7. Restaurer Firefox

1. Lancer Firefox une première fois (crée le profil)
2. Se connecter à **Firefox Sync** → bookmarks, historique, onglets épinglés reviennent
3. Les extensions (Bitwarden, SponsorBlock) sont déjà installées via Nix

Se connecter à **Bitwarden** → pointer vers `https://vault.example.com`

---

## 8. Apps App Store

Les masApps sont commentées dans la config (problème Touch ID).  
Les installer manuellement depuis l'App Store :

- Mp3tag
- MediaInfo
- Hover for Safari
- WhatsApp Messenger
- News Explorer
- Search Engines for Safari
- DeArrow
- SponsorBlock

---

## 9. cmux NIGHTLY (DMG manuel)

La version Homebrew (`cmux` cask) est en stable. Pour utiliser la nightly
(nécessaire pour les dead keys macOS — option+e → é sur clavier français/ISO,
bug `macos-option-as-alt` non respecté en stable, issues #691/#725/#1349/
#1469/#2369), télécharger le DMG :

```bash
open https://www.cmux.dev/  # ou https://github.com/manaflow-ai/cmux/releases
# Télécharger cmux-nightly-macos.dmg, monter, glisser dans /Applications
```

Au premier lancement, le rebuild Nix a déjà écrit `~/.config/cmux/cmux.json`
avec `automation.claudeBinaryPath` → cmux lancera claude via le wrapper bypass
dès la première session.

---

## 10. Login Claude Code

Le token OAuth est stocké dans `~/.claude.json` (pas géré par Nix). Au premier
lancement de `claude` depuis une session cmux :

```bash
claude
# → ouvre le navigateur pour login Anthropic
```

Une fois loggé, le token persiste dans `~/.claude.json`.

---

## Ajouter un nouveau Mac à la config

Si c'est une nouvelle machine (pas kamino) :

```bash
# 1. Créer hosts/<nom>/default.nix en copiant kamino comme base
cp -r ~/.config/nix/hosts/kamino ~/.config/nix/hosts/<nom>

# 2. Ajuster nixpkgs.hostPlatform selon l'architecture :
#    aarch64-darwin  → Apple Silicon (M1, M2, M3, M4...)
#    x86_64-darwin   → Intel

# 3. Changer networking.hostName

# 4. Créer home/<nom>/ en copiant kamino comme base
cp -r ~/.config/nix/home/kamino ~/.config/nix/home/<nom>

# 5. Ajouter dans flake.nix :
#    darwinConfigurations."<nom>" = nix-darwin.lib.darwinSystem { ... }

# 6. Générer une clé age et mettre à jour .sops.yaml
age-keygen -o ~/.config/sops/age/keys.txt
# → ajouter la clé publique dans .sops.yaml

# 7. Commiter et pusher
nixrb
```
