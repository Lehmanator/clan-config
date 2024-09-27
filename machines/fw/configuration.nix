{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/gnome.nix
  ];

  # Locale service discovery and mDNS
  services.avahi.enable = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_22382X803513";

  clan.localsend.ipv4Addr = "192.168.57.2/24";
  clan.core = {
    deployment.requireExplicitUpdate = true;
    networking = {

      # The build SSH node where nixos-rebuild will be executed.
      # format: user@host:port&SSH_OPTION=SSH_VALUE
      # examples:
      # - machine.example.com
      # - user@machine2.example.com
      # - root@example.com:2222&IdentityFile=/path/to/private/key
      # buildHost = "root@wyse.local";

      # The target SSH node for deployment.
      # targetHost = "sam@fw.local";
    };
  };
}
