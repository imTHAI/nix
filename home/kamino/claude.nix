{ config, lib, pkgs, ... }:
let
  # Static settings.json — secrets are injected at activation time via sops.
  # Materialized to a Nix store file so the activation script doesn't have to
  # heredoc the JSON inline (single quotes in hook commands broke '<<<' quoting).
  staticJsonFile = pkgs.writeText "claude-settings-base.json" (builtins.toJSON {
    env.CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
    permissions = {
      allow = [
          "Bash(npx vite *)"
          # Explicit allow for Claude's own config dir — bypassPermissions mode doesn't
          # override the hardcoded .claude/ directory protection in the TUI.
          "Read(${config.home.homeDirectory}/.claude/**)"
          "Write(${config.home.homeDirectory}/.claude/**)"
          "Edit(${config.home.homeDirectory}/.claude/**)"
        ];
      deny  = [
        # Destruction fichiers système critiques
        "Bash(rm -rf /)"
        "Bash(rm -rf /*)"
        "Bash(rm -rf ~*)"
        "Bash(rm*-rf*/etc*)"
        "Bash(rm*-rf*/usr*)"
        "Bash(rm*-rf*/boot*)"
        "Bash(rm*-rf*/bin*)"
        # Écrasement de disques
        "Bash(dd*of=/dev/*)"
        # Téléchargement direct vers shell (curl|bash, wget|sh, etc.)
        "Bash(*curl*|*bash*)"
        "Bash(*curl*|*sh*)"
        "Bash(*wget*|*bash*)"
        "Bash(*wget*|*sh*)"
        # Fork bomb
        "Bash(:(){ :|:& };:)"
        # Git push force
        "Bash(git push --force*)"
        "Bash(git push -f *)"
      ];
    };
    model = "sonnet";
    statusLine = {
      type    = "command";
      command = "bash /Users/pbear/.claude/statusline-command.sh";
    };
    enabledPlugins = {
      "context7@claude-plugins-official" = true;
      "cloudflare@cloudflare"            = false;
      "github@claude-plugins-official"   = true;
      "claude-mem@thedotmack"            = true;
      "superpowers@claude-plugins-official" = true;
    };
    extraKnownMarketplaces = {
      cloudflare.source = { source = "github"; repo = "cloudflare/skills"; };
      thedotmack.source = { source = "github"; repo = "thedotmack/claude-mem"; };
    };
    tui         = "fullscreen";
    defaultMode = "bypassPermissions";
    skipDangerousModePermissionPrompt = true;
    theme       = "auto";
    mcpServers.devonthink = {
      type    = "sse";
      url     = "http://localhost:8420/sse";
      headers = {
        Authorization = "Bearer 66BYUbfDvTvlNjfdJmDDB2KG-4ZD20X0C37tD4fhuEc";
      };
    };
    mcpServers.context7 = {
      command = "npx";
      args    = [ "-y" "@upstash/context7-mcp" ];
      env     = {
        UPSTASH_REDIS_REST_URL   = "__UPSTASH_URL__";
        UPSTASH_REDIS_REST_TOKEN = "__UPSTASH_TOKEN__";
      };
    };
    hooks = {
      # rtk (Rust Token Killer) rewrites Bash commands transparently before
      # execution to compress output (-80% tokens on git/grep/test/etc).
      # Installed via homebrew.brews in hosts/kamino/default.nix.
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type    = "command";
              command = "rtk hook claude";
            }
          ];
        }
      ];
      Stop = [
        {
          matcher = "";
          hooks = [
            {
              type    = "command";
              command = "afplay $HOME/.claude/sounds/finish.mp3";
            }
          ];
        }
      ];
      Notification = [
        {
          matcher = "";
          hooks = [
            {
              type    = "command";
              command = "afplay $HOME/.claude/sounds/need-human.mp3";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          matcher = "Edit|Write";
          hooks = [
            {
              type    = "command";
              # Fires after any Edit/Write; injects a reminder into model context when the
              # edited file lives inside ~/.config/nix/ so the Gitmoji commit step is never skipped.
              command = ''f=$(jq -r '.tool_input.file_path // ""'); case "$f" in */.config/nix/*) echo '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"RAPPEL NIX: fichier modifie dans ~/.config/nix/ — fournir message commit Gitmoji et rappeler push GitHub."}}' ;; esac'';
            }
          ];
        }
      ];
    };
  });
in
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."upstash_url".sopsFile   = ../../secrets/kamino/claude.yaml;
    secrets."upstash_token".sopsFile = ../../secrets/kamino/claude.yaml;
  };

  home.file = {
    ".claude/CLAUDE.md".source       = ./claude/CLAUDE.md;
    ".claude/RTK.md".source          = ./claude/RTK.md;
    ".claude/rules/python.md".source          = ./claude/rules/python.md;
    ".claude/sounds/finish.mp3".source        = ./claude/sounds/finish.mp3;
    ".claude/sounds/need-human.mp3".source    = ./claude/sounds/need-human.mp3;
  };

  # npm global prefix outside the Nix store so claude-code can self-update
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # Bootstrap claude-code via npm on first install; auto-updates handle subsequent upgrades.
  # PATH must include the system profile (where the Nix-installed claude lives during
  # the same activation that swaps profiles) AND nodejs/bin, since npm's post-install
  # spawns `sh -c node install.cjs` and resolves `node` from PATH, not from npm's own dir.
  home.activation.installClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:/run/current-system/sw/bin:$HOME/.npm-global/bin:$PATH"
    if ! command -v claude &>/dev/null && ! [ -f "$HOME/.npm-global/bin/claude" ]; then
      ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
    fi
  '';

  # Write settings.json at activation with secrets injected from sops-decrypted files.
  # Depends on "sops-nix" (not "sops") — that's the actual DAG entry name used by sops-nix's HM module.
  # Falls back to tokenless config if the LaunchAgent hasn't decrypted secrets yet (first boot).
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    _url_file="${config.sops.secrets."upstash_url".path}"
    _token_file="${config.sops.secrets."upstash_token".path}"

    if [ -f "$_url_file" ] && [ -f "$_token_file" ]; then
      ${pkgs.jq}/bin/jq \
        --arg url   "$(cat "$_url_file")" \
        --arg token "$(cat "$_token_file")" \
        '.mcpServers.context7.env.UPSTASH_REDIS_REST_URL   = $url   |
         .mcpServers.context7.env.UPSTASH_REDIS_REST_TOKEN = $token' \
        ${staticJsonFile} \
        > "$HOME/.claude/settings.json"
    else
      install -m 0644 ${staticJsonFile} "$HOME/.claude/settings.json"
    fi
  '';
}
