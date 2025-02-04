{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
  clan.localsend.ipv4Addr = "192.168.57.2/24";
  clan.core.deployment.requireExplicitUpdate = true;
}
