{lib, ...}: {
  boot.loader.grub.efiSupport = lib.mkDefault true;
  boot.loader.grub.efiInstallAsRemovable = lib.mkDefault true;

  disko.devices = {
    disk.main = {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            label = "esp";
            start = "1MiB";
            end = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountOptions = ["umask=0077"];
              mountpoint = "/boot";
            };
          };
          nixos = {
            label = "nixos";
            start = "512MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "nixos";
              content = {
                type = "lvm_pv";
                vg = "nixos";
              };
            };
          };
          # boot = {
          #   size = "1M";
          #   type = "EF02"; # for grub MBR
          #   priority = 1;
          # };
        };
      };
    };
    lvm_vg.nixos = {
      type = "lvm_vg";
      lvs = {
        root = {
          size = "";
          content = {
            type = "btrfs";
            subvolumes = {
              "root" = {
                mountpoint = "/";
              };
              "nix" = {
                mountpoint = "/nix";
              };
              "state" = {
                mountpoint = "/state";
              };
              "persist" = {
                mountpoint = "/persist";
              };
            };
          };
        };
        swap = {
          name = "swap";
          size = "100%FREE";
          content.type = "swap";
        };
      };
    };
  };

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
}
