{ config, ... }:
let
  username = config.networking.hostName;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/gnome.nix
  ];

  clan.core = {
    machineIcon = ./logo.svg;
    machineDescription = "Dell Wyse mini desktop";
    networking = {
      # Set this for clan commands use ssh i.e. `clan machines update`
      # If you change the hostname, you need to update this line to root@<new-hostname>
      # This only works however if you have avahi running on your admin machine else use IP
      # targetHost = pkgs.lib.mkDefault "${user}@${config.networking.hostName}";
      /*
        After fw is deployed, uncomment the following lines.
        This will allow wyse to share the VPN overlay network with fw
        The networkId is generated by the first deployment of fw
      */
      zerotier = {
        # moon.stableEndpoints = [ "home" ];
        # networkId = builtins.readFile ../${host}/facts/zerotier-network-id;
        controller = {
          enable = true;
          public = false;
        };
      };
    };
  };

  # TODO: Combine LVM, LUKS, BTRFS, interactive login, impermanence
  # - https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-interactive-login.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-lvm.nix
  # ssh root@flash-installer.local lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT
  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.0025385821413a6b";

  # Locale service discovery and mDNS
  services.avahi.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
