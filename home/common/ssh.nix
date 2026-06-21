{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent      = "yes";
        identityFile        = "~/.ssh/id_ed25519";
        serverAliveInterval = 60;
        serverAliveCountMax = 10;
        controlMaster       = "auto";
        controlPath         = "~/.ssh/control-%r@%h:%p";
        controlPersist      = "10m";
        kexAlgorithms       = [
          "sntrup761x25519-sha512"
          "curve25519-sha256"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "diffie-hellman-group-exchange-sha256"
        ];
        extraOptions = {
          TCPKeepAlive      = "yes";
          HostKeyAlgorithms = "rsa-sha2-512,rsa-sha2-256,ssh-ed25519";
          MACs              = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com";
        };
      };
      "coruscant" = { hostname = "10.0.0.2";                   user = "root";  };
      "scarif"    = { hostname = "2001:db8:aaa:e22:10:0:2:49"; user = "pbear"; };
      "udm"       = { hostname = "192.168.0.1";                user = "root";  };
      "ubuntu"    = { hostname = "10.0.0.11"; };
      "jakku"     = { hostname = "2001:db8:aaa:e22:10:0:2:18"; user = "pbear"; };
      "kamino"    = { hostname = "192.168.0.3";                user = "pbear"; };
    };
  };
}
