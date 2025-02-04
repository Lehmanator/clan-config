{
  inputs,
  config,
  lib,
  ...
}: {
  #
  # NOTE: This file contains config using clanModules shared by all nixosConfigurations.
  #
  imports = with inputs.clan-core.clanModules; [
    localsend # Tags: all | gui ?
    static-hosts # Tags: all
    trusted-nix-caches # Tags: all
    zerotier-static-peers # Tags: all
    zt-tcp-relay # Tags: all | portable
  ];

  clan = let
    networkId = builtins.readFile "${config.clan.core.settings.directory}/machines/wyse/facts/zerotier-network-id";
  in {
    core.deployment.requireExplicitUpdate = lib.mkDefault false;
    core.networking.zerotier.networkId = networkId;
    localsend = {
      # displayName = config.networking.hostName;
      ipv4Addr = "192.168.56.2/24";
    };
    static-hosts = {
      topLevelDomain = "lehman.run";
      excludeHosts = ["nixos"];
    };
    zt-tcp-relay.port = 4443;
    zerotier-static-peers = {
      networkIds = [networkId];
      networkIps = lib.unique (builtins.filter (i: i != null && i != "") (lib.mapAttrsToList (
          _: v: v.config.clan.core.facts.services.zerotier.public.zerotier-ip.value or null
        )
        inputs.self.nixosConfigurations));
    };
  };

  # After system installed/deployed use:
  # $ clan secrets get {machine_name}-user-password
  users.groups.admins.members = [config.clan.user-password.user];
  users.groups.users = {
    members = [config.clan.user-password.user];
    gid = 100;
  };
  users.groups.${config.clan.user-password.user} = {
    members = [config.clan.user-password.user];
    gid = 1000;
  };
  users.users.${config.clan.user-password.user} = {
    group = config.clan.user-password.user;
    extraGroups = ["wheel"];
    uid = 1000;
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };

  programs.ssh.knownHostsFiles = builtins.attrValues (builtins.mapAttrs (n: v: v.config.clan.core.vars.generators.openssh.files."ssh.id_ed25519.pub".path) (builtins.removeAttrs inputs.self.nixosConfigurations ["clan-installer"]));
}
