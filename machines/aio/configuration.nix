{ inputs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    (inputs.self + /modules/gnome.nix)
  ];

  # TODO: Combine LVM, LUKS, BTRFS, interactive login, impermanence
  # - https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-interactive-login.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-lvm.nix
  # ssh root@flash-installer.local lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT
  disko.devices.disk.main.device = "/dev/disk/by-id/wwn-0x5000c5003f7bdb2b";
  clan.localsend.ipv4Addr = "192.168.58.2/24";
}
