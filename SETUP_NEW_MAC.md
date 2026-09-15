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

> **Gotcha Full Disk Access** : à faire *avant* le premier build. macOS bloque plusieurs
> opérations sinon (`mkdir: Operation not permitted` sur `~/Library/Application Support/*`,
> échec de suppression de casks Homebrew) — le process "responsable" (celui qui tient le
> terminal, ex. cmux, Terminal, iTerm) n'a pas accès complet au disque. Si tu passes par cmux,
> ces erreurs cassent silencieusement une partie de l'activation home-manager (voir gotcha
> sops-nix ci-dessous) sans que `darwin-rebuild switch` s'arrête forcément avec un code de
> sortie évident. Fix :
> **Réglages Système → Confidentialité et sécurité → Accès complet au disque** → ajouter et
> activer l'appli qui tient ton terminal (ex. `cmux.app` dans `/Applications/Nix Apps/`).
> Redémarrer l'appli après.

> **Gotcha SSH** : `sudo darwin-rebuild` s'exécute en `root`, dont le `$HOME` retombe sur
> `/var/root` (pas `/Users/pbear`, qui ne lui appartient pas). Si la flake fetch un repo privé
> en SSH (ex. `nix-private`), root n'a pas accès à tes clés → `git@github.com: Permission
> denied (publickey)`. Fix :
> ```bash
> sudo mkdir -p /var/root/.ssh
> sudo ln -s /Users/pbear/.ssh/id_ed25519 /var/root/.ssh/id_ed25519
> sudo ln -s /Users/pbear/.ssh/known_hosts /var/root/.ssh/known_hosts
> ```
> (Sans risque : root a de toute façon accès total à `/Users/pbear` via sudo.)

```bash
# Pour kamino (Mac Mini M1) :
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix#kamino

# Pour un nouveau Mac (nouveau nom à créer dans hosts/) :
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix#<nom>
```

> **Gotcha `/etc/nix/nix.custom.conf`** : le Determinate Systems installer (étape 2) crée ce
> fichier, et nix-darwin refuse d'écraser un fichier `/etc/nix/*` qu'il ne gère pas encore →
> `error: Unexpected files in /etc, aborting activation`. Fix (vérifier le contenu avant si tu
> veux être sûr de rien perdre, mais c'est un fichier généré par l'installer, rien de custom) :
> ```bash
> sudo mv /etc/nix/nix.custom.conf /etc/nix/nix.custom.conf.before-nix-darwin
> ```
> Puis relancer la commande `darwin-rebuild switch` ci-dessus.

> **Gotcha sops-nix / activation qui s'arrête en silence** : le module home-manager de
> sops-nix fait `launchctl bootout ... && true` puis `launchctl bootstrap ...` sans aucune
> tolérance d'erreur. `bootstrap` échoue très souvent juste après un `bootout` (race connue de
> `launchd`, macOS n'a pas eu le temps de désenregistrer le job) → `Bootstrap failed: 5:
> Input/output error`. Comme le script d'activation tourne avec `set -e`, **toute l'activation
> home-manager s'arrête net à cette étape** — et donc tout ce qui vient après dans l'ordre du
> script (`claudeSettings`, `installClaudeCode`, `cmuxConfig`, et surtout `linkGeneration` qui
> pose réellement `.zshrc`/`.gitconfig`/starship/direnv/cmux) n'est jamais exécuté. Résultat :
> `darwin-rebuild switch` peut planter à cette étape en laissant croire que seul un cask
> Homebrew a un souci, alors qu'en fait **rien du user-space n'a été appliqué**. Diagnostic :
> vérifier `ls ~/.local/state/nix/profiles/home-manager` (vide = l'activation n'a jamais été
> "commitée") et `ls ~/.zshrc`. Fix ponctuel (en attendant un vrai correctif upstream ou un
> override dans la flake) :
> ```bash
> # Repérer le script d'activation home-manager fraîchement construit
> find /nix/store -maxdepth 1 -iname '*home-manager-generation' | tail -1
>
> # En faire une copie modifiable, et rendre les lignes launchctl tolérantes à l'échec
> # (bootout ... || true  +  sleep 1  +  bootstrap ... || true), idem pour tout autre
> # `_iNote "Activating %s" "X"` qui planterait avec `set -e`.
>
> # Puis relancer l'activation directement, sans passer par sudo (pas besoin de root ici) :
> HOME_MANAGER_BACKUP_EXT=before-hm /chemin/vers/la/copie/patchée/activate
> ```
> Une fois l'activation user-space terminée, relancer un `sudo darwin-rebuild switch` propre
> (sans patch) pour confirmer que tout tient — il devrait maintenant passer plus loin puisque
> le LaunchAgent sops-nix est déjà bootstrappé.

> **Gotcha `npm install -g @anthropic-ai/claude-code` en EACCES** : la flake installe déjà
> `claude` via npm pendant l'activation (étape `installClaudeCode` dans le home-manager
> generation), avec `NPM_CONFIG_PREFIX="$HOME/.npm-global"` pour éviter d'écrire dans le store
> Nix (read-only). Si tu lances cette commande toi-même à la main *sans* ce réglage — par
> exemple pour dépanner pendant que l'activation est cassée par un des gotchas ci-dessus — npm
> retombe sur le préfixe par défaut du binaire `node` fourni par Nix, qui pointe dans
> `/nix/store/...` → `EACCES: permission denied, mkdir '/nix/store/.../lib'`. Ce n'est *pas* un
> problème de brew vs npm, juste un préfixe npm mal configuré. Si besoin de dépanner à la main :
> ```bash
> export NPM_CONFIG_PREFIX="$HOME/.npm-global"
> export PATH="$HOME/.npm-global/bin:$PATH"
> npm install -g @anthropic-ai/claude-code
> ```
> Mieux : régler d'abord les gotchas qui bloquent l'activation (Full Disk Access, sops-nix,
> herdr) et laisser la flake s'en charger normalement.

> La première fois prend plus longtemps — tout est téléchargé depuis cache.nixos.org.

Le rebuild remet automatiquement en place :
- Système : packages CLI, dock, Finder, GC, homebrew (casks + brews dont `rtk`)
- User : zsh + plugins, git, ssh, starship, direnv, cmux, gh-dash
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

## 7. Restaurer `~/Applications/bin`

Scripts perso non trackés dans ce repo (ex: `torrent_watcher.py`, `backup_supabase.py`,
`mount_smb.py`, `csv2ynab.py`...), sauvegardés via rsync sur iCloud Drive :

```bash
cp -R "$HOME/Library/Mobile Documents/com~apple~CloudDocs/<dossier-backup>" ~/Applications/bin
```

Le LaunchAgent `torrentwatcher` est géré par Nix (`home/kamino/torrent-watcher.nix`) et se
recrée tout seul au rebuild — il pointe vers `~/Applications/bin/torrent_watcher.py`, donc
cette étape doit précéder le premier lancement du service (sinon il tourne en échec jusqu'au
retour du script, sans conséquence — `KeepAlive` le relance).

---

## 8. Repointer les bibliothèques externes

Rien à restaurer (les données sont sur `/Volumes/TB_500Go`, externe), juste à indiquer le
chemin au premier lancement de chaque app :

- **Calibre** → `/Volumes/TB_500Go/Librairie Calibre`
- **Photos** → `/Volumes/TB_500Go/Images/Photos.photoslibrary`

---

## 9. Restaurer Firefox (optionnel)

Safari est le navigateur principal désormais — Firefox n'est utile que si tu en as encore
besoin ponctuellement.

1. Lancer Firefox une première fois (crée le profil)
2. Se connecter à **Firefox Sync** → bookmarks, historique, onglets épinglés reviennent
3. Les extensions (Bitwarden, SponsorBlock) sont déjà installées via Nix

Pour **Bitwarden** en général (pas lié à Firefox) : app desktop (liste ci-dessous) ou
extension Safari → pointer vers le vault self-hosted (URL dans `hosts.nix` du repo privé
[`nix-private`](https://github.com/imTHAI/nix-private)).

---

## 10. Apps App Store

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

## 11. Apps hors App Store, ni Nix ni Homebrew

Téléchargements directs à refaire à la main :

- Xcode (developer.apple.com ou App Store selon la taille)
- DEVONthink
- TeamViewer
- NordVPN
- Day One
- Alacritty
- iTerm
- PowerPhotos
- VueScan
- Windows App

Une fois DEVONthink installé, ouvrir la base `RAG` (mémoire documentaire des projets, utilisée
par le MCP devonthink de Claude Code) — invisible au MCP tant qu'elle n'est pas ouverte dans l'app.

---

## 12. Login Claude Code

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
