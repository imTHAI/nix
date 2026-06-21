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
      "agent-skills@addy-agent-skills"      = true;
      "context7@claude-plugins-official"    = true;
      "cloudflare@cloudflare"               = false;
      "github@claude-plugins-official"      = false;
      "claude-mem@thedotmack"               = true;
      "superpowers@claude-plugins-official" = true;
    };
    extraKnownMarketplaces = {
      addy-agent-skills.source = { source = "github"; repo = "addyosmani/agent-skills"; };
      cloudflare.source        = { source = "github"; repo = "cloudflare/skills"; };
      thedotmack.source        = { source = "github"; repo = "thedotmack/claude-mem"; };
    };
    tui         = "fullscreen";
    defaultMode = "bypassPermissions";
    skipDangerousModePermissionPrompt = true;
    theme       = "auto";
    # context7 credentials injected here so the plugin can read them from settings.json.
    # nixos and devonthink are configured via ~/.claude.json (claudeMcpServers activation).
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
    secrets."username".sopsFile    = ../../secrets/kamino/claude.yaml;
    secrets."password".sopsFile    = ../../secrets/kamino/claude.yaml;
    secrets."exa_api_key".sopsFile = ../../secrets/kamino/claude.yaml;
  };

  home.file = {
    ".claude/CLAUDE.md".source       = ./claude/CLAUDE.md;
    ".claude/RTK.md".source          = ./claude/RTK.md;
    ".claude/rules/python.md".source          = ./claude/rules/python.md;
    ".claude/sounds/finish.mp3".source        = ./claude/sounds/finish.mp3;
    ".claude/sounds/need-human.mp3".source    = ./claude/sounds/need-human.mp3;
    ".claude/statusline-command.sh".source    = ./claude/statusline-command.sh;
    ".claude/settings.local.json".source     = ./claude/settings.local.json;
    ".claude/skills/meta-prompt-creator/SKILL.md".source                                    = ./claude/skills/meta-prompt-creator/SKILL.md;
    ".claude/skills/meta-prompt-creator/references/anthropic-best-practices.md".source      = ./claude/skills/meta-prompt-creator/references/anthropic-best-practices.md;
    ".claude/skills/meta-prompt-creator/references/anti-patterns.md".source                 = ./claude/skills/meta-prompt-creator/references/anti-patterns.md;
    ".claude/skills/meta-prompt-creator/references/clarity-principles.md".source            = ./claude/skills/meta-prompt-creator/references/clarity-principles.md;
    ".claude/skills/meta-prompt-creator/references/context-management.md".source            = ./claude/skills/meta-prompt-creator/references/context-management.md;
    ".claude/skills/meta-prompt-creator/references/few-shot-patterns.md".source             = ./claude/skills/meta-prompt-creator/references/few-shot-patterns.md;
    ".claude/skills/meta-prompt-creator/references/openai-best-practices.md".source         = ./claude/skills/meta-prompt-creator/references/openai-best-practices.md;
    ".claude/skills/meta-prompt-creator/references/prompt-templates.md".source              = ./claude/skills/meta-prompt-creator/references/prompt-templates.md;
    ".claude/skills/meta-prompt-creator/references/reasoning-techniques.md".source          = ./claude/skills/meta-prompt-creator/references/reasoning-techniques.md;
    ".claude/skills/meta-prompt-creator/references/system-prompt-patterns.md".source        = ./claude/skills/meta-prompt-creator/references/system-prompt-patterns.md;
    ".claude/skills/meta-prompt-creator/references/xml-structure.md".source                 = ./claude/skills/meta-prompt-creator/references/xml-structure.md;
    ".claude/skills/meta-prompt-creator/references/gemini-best-practices.md".source         = ./claude/skills/meta-prompt-creator/references/gemini-best-practices.md;
    ".claude/skills/exa-search/SKILL.md".source = ./claude/skills/exa-search/SKILL.md;
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

  # Merge user-level MCP servers into ~/.claude.json (the file the CLI actually reads
  # for User MCPs, as opposed to ~/.claude/settings.json which is for plugins/settings).
  # jq --argjson preserves the rest of the file (tips history, counters, etc.).
  home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _claude_json="$HOME/.claude.json"
    [ -f "$_claude_json" ] || echo '{}' > "$_claude_json"
    _tmp=$(mktemp)
    ${pkgs.jq}/bin/jq '
      .mcpServers.nixos = {"type":"stdio","command":"uvx","args":["mcp-nixos"],"env":{}} |
      .mcpServers.devonthink = {
        "type":"stdio",
        "command":"/Applications/DEVONthink.app/Contents/Library/LoginItems/DEVONthink MCP.app/Contents/MacOS/DEVONthink MCP",
        "args":["--stdio"],"env":{}
      }
    ' "$_claude_json" > "$_tmp" && mv "$_tmp" "$_claude_json"
  '';

  # Regenerate SMB credentials file from sops-decrypted secrets.
  # 0600 so Finder/mount_smbfs won't reject it as world-readable.
  home.activation.smbCredentials = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    _user_file="${config.sops.secrets."username".path}"
    _pass_file="${config.sops.secrets."password".path}"
    if [ -f "$_user_file" ] && [ -f "$_pass_file" ]; then
      install -m 0600 /dev/null "$HOME/.ssh/smb_credentials"
      printf 'username=%s\npassword=%s\n' \
        "$(cat "$_user_file")" "$(cat "$_pass_file")" \
        > "$HOME/.ssh/smb_credentials"
    fi
  '';

  # Write Exa API key to a 0600 file so the exa-search skill can cat it at runtime.
  home.activation.exaApiKey = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    _key_file="${config.sops.secrets."exa_api_key".path}"
    if [ -f "$_key_file" ]; then
      mkdir -p "$HOME/.config/exa"
      install -m 0600 /dev/null "$HOME/.config/exa/api-key"
      cat "$_key_file" > "$HOME/.config/exa/api-key"
    fi
  '';
}
