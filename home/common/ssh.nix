{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
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
      "coruscant" = { Hostname = "10.0.0.2";                   User = "root";  };
      "scarif"    = { Hostname = "2001:db8:aaa:e22:10:0:2:49"; User = "pbear"; };
      "udm"       = { Hostname = "192.168.0.1";                User = "root";  };
      "ubuntu"    = { Hostname = "10.0.0.11"; };
      "jakku"     = { Hostname = "2001:db8:aaa:e22:10:0:2:18"; User = "pbear"; };
      "kamino"    = { Hostname = "192.168.0.3";                User = "pbear"; };
      "redacted-host" = { Hostname = "redacted.example.com"; Port = 222; User = "root"; };
    };
  };
}
