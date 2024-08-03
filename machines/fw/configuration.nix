{ config, user, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/gnome.nix
  ];

  # Locale service discovery and mDNS
  services.avahi.enable = true;

  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_22382X803513";
  clan.core = {
    machineDescription = "Framework Laptop 13";
    machineIcon = ./logo.png;
  };
  nixpkgs.hostPlatform = "x86_64-linux";
}
