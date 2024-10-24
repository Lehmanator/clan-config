{ inputs, config, lib, pkgs, ... }:
{
  imports = with inputs.clan-core.clanModules; [
    localsend             # Tags: all | gui ?
    root-password         # Tags: all
    sshd                  # Tags: all
    static-hosts          # Tags: all
    trusted-nix-caches    # Tags: all
    user-password         # Tags: all
    zerotier-static-peers # Tags: all
    zt-tcp-relay          # Tags: all | portable
  ];

  clan = 
  let
    networkId = builtins.readFile "${config.clan.core.clanDir}/machines/wyse/facts/zerotier-network-id";
  in
  {
    core.networking.zerotier.networkId = networkId;
    localsend = {
      # displayName = config.networking.hostName;
      ipv4Addr = "192.168.56.2/24";
    };
    static-hosts = {
      topLevelDomain = "lehman.run";
      excludeHosts = ["nixos"];
    };
    user-password = {
      prompt = true;
      user = "sam";
    };
    zt-tcp-relay.port = 4443;
    zerotier-static-peers = {
      networkIds = [networkId];
      networkIps = lib.unique (builtins.filter (i: i != null && i != "") (lib.mapAttrsToList (_: v: v.config.clan.core.facts.services.zerotier.public.zerotier-ip.value or null
      ) inputs.self.nixosConfigurations));
    };
  };
}
