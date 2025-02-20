{...}: {
  clan.localsend.ipv4Addr = "192.168.56.2/24";

  # TODO: Combine LVM, LUKS, BTRFS, interactive login, impermanence
  # - https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-interactive-login.nix
  # - https://github.com/nix-community/disko/blob/master/example/luks-lvm.nix
  # ssh root@flash-installer.local lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT

  # This machine has an old Windows disk connected.
  #  so we'll temporarily allow using NTFS partitions at boot.
  # https://wiki.nixos.org/wiki/NTFS
  # https://nixos.wiki/wiki/NTFS
  # TODO: Make sure this is correct.
  boot.supportedFilesystems = ["ntfs"];
  # fileSystems."/mnt/hybrid-drive-750GB" = {
  #   device = "/dev/sda1";
  #   fsType = "ntfs-3g";
  #   options = ["rw" "uid=1000"];
  # };
}
