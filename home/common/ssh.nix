{ inputs, lib, ... }:
let
  # Host addresses/users live in the private repo so this one can stay public.
  private = import "${inputs.nix-private}/hosts.nix";
  toBlock = h: { Hostname = h.host; }
    // lib.optionalAttrs (h ? user) { User = toString h.user; }
    // lib.optionalAttrs (h ? port) { Port = toString h.port; };
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      # Outbound port 22 is unreliable on this network (intermittent blackhole),
      # so route GitHub through its official SSH-over-443 endpoint permanently.
      # https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port
      "github.com" = {
        Hostname = "ssh.github.com";
        Port     = 443;
        User     = "git";
      };
      "*" = {
        AddKeysToAgent      = "yes";
        IdentityFile        = "~/.ssh/id_ed25519";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 10;
        ControlMaster       = "auto";
        ControlPath         = "~/.ssh/control-%r@%h:%p";
        ControlPersist      = "10m";
        TCPKeepAlive        = "yes";
        HostKeyAlgorithms   = "rsa-sha2-512,rsa-sha2-256,ssh-ed25519";
        MACs                = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com";
        KexAlgorithms       = [
          "sntrup761x25519-sha512"
          "curve25519-sha256"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "diffie-hellman-group-exchange-sha256"
        ];
      };
    } // lib.mapAttrs (_: toBlock) private.ssh;
  };
}
