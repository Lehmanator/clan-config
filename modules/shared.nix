{ clan-core, ... }:
{
  imports = [
    clan-core.clanModules.sshd
    clan-core.clanModules.root-password
    clan-core.clanModules.trusted-nix-caches
  ];
}
