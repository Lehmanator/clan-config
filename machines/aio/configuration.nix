{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/gnome.nix
  ];

  clan.localsend.ipv4Addr = "192.168.58.2/24";
  clan.core = {
    networking = {
      # buildHost = "root@wyse.local";
      # Set this for clan commands use ssh i.e. `clan machines update`
      # If you change the hostname, you need to update this line to root@<new-hostname>
      # This only works however if you have avahi running on your admin machine else use IP
      # targetHost = pkgs.lib.mkDefault "${user}@${config.networking.hostName}";
      # targetHost = "root@aio.local";
      zerotier = {
        # moon.stableEndpoints = [ "home" ];
        # networkId = builtins.readFile ../${host}/facts/zerotier-network-id;
      };
    };
  };

  # TODO: Combine LVM, LUKS, BTRFS, interactive login, impermanence
  # - https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-interactive-login.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-lvm.nix
  # ssh root@flash-installer.local lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT
  disko.devices.disk.main.device = "/dev/disk/by-id/wwn-0x5000c5003f7bdb2b";

  # Locale service discovery and mDNS
  services.avahi.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
