{ inputs, config, lib, pkgs, ... }:
{
  imports = with inputs.clan-core.clanModules; [
    localsend           # Tags: all | gui ?
    root-password       # Tags: all
    sshd                # Tags: all
    static-hosts        # Tags: all
    trusted-nix-caches  # Tags: all
    user-password       # Tags: all
  ];

  clan = {
    localsend.defaultLocation = "/home/${config.clan.user-password.user}/Downloads";
    static-hosts = {
      topLevelDomain = "lehman.run";
      excludeHosts = ["nixos"];
    };
    user-password = {
      prompt = true;
      user = "sam";
    };
  };
}
