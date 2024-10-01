{ inputs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    inputs.self.nixosProfiles.gnome
  ];
  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_22382X803513";
  clan.localsend.ipv4Addr = "192.168.57.2/24";
  clan.core.deployment.requireExplicitUpdate = true;
}
