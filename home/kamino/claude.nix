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

  # Write settings.json at activation with secrets injected from sops-decrypted files
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" "sops" ] ''
    _url=$(cat "${config.sops.secrets."upstash_url".path}")
    _token=$(cat "${config.sops.secrets."upstash_token".path}")

    ${pkgs.jq}/bin/jq \
      --arg url   "$_url" \
      --arg token "$_token" \
      '.mcpServers.context7.env.UPSTASH_REDIS_REST_URL   = $url   |
       .mcpServers.context7.env.UPSTASH_REDIS_REST_TOKEN = $token' \
      <<< '${staticJson}' \
      > "$HOME/.claude/settings.json"
  '';
}
