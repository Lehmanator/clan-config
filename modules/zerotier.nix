{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.clan-core.clanModules.zerotier-static-peers
    inputs.clan-core.clanModules.zt-tcp-relay
  ];

  clan.zt-tcp-relay.port = 4443;
  clan.zerotier-static-peers = {
    excludeHosts = [config.networking.hostName];
    networkIds = builtins.filter (i: i != null) (builtins.attrValues (builtins.mapAttrs (n: v: v.config.clan.core.facts.services.zerotier.public.zerotier-network-id.value or null) (builtins.removeAttrs inputs.self.nixosConfigurations ["clan-installer"])));
    networkIps = builtins.attrValues (builtins.mapAttrs (n: v: v.config.clan.core.facts.services.zerotier.public.zerotier-ip.value) (builtins.removeAttrs inputs.self.nixosConfigurations ["clan-installer"]));
  };
  # clan.core.networking.zerotier.networkId = networkId;
}
