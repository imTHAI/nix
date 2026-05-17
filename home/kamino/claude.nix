{ config, lib, pkgs, ... }:
let
  # Static settings.json — secrets are injected at activation time via sops
  staticJson = builtins.toJSON {
    env.CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
    permissions = {
      allow = [ "Bash(npx vite *)" ];
      deny  = [
        "Bash(rm -rf /)"
        "Bash(rm -rf /*)"
        "Bash(rm -rf ~*)"
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
    mcpServers.context7 = {
      command = "npx";
      args    = [ "-y" "@upstash/context7-mcp" ];
      env     = {
        UPSTASH_REDIS_REST_URL   = "__UPSTASH_URL__";
        UPSTASH_REDIS_REST_TOKEN = "__UPSTASH_TOKEN__";
      };
    };
  };
in
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."upstash_url".sopsFile   = ../../secrets/kamino/claude.yaml;
    secrets."upstash_token".sopsFile = ../../secrets/kamino/claude.yaml;
  };

  home.file = {
    ".claude/CLAUDE.md".source       = ./claude/CLAUDE.md;
    ".claude/rules/python.md".source = ./claude/rules/python.md;
  };

  # npm global prefix outside the Nix store so claude-code can self-update
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # Bootstrap claude-code via npm on first install; auto-updates handle subsequent upgrades
  home.activation.installClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
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
        <<< '${staticJson}' \
        > "$HOME/.claude/settings.json"
    else
      printf '%s' '${staticJson}' > "$HOME/.claude/settings.json"
    fi
  '';
}
