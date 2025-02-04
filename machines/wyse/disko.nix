{lib, ...}: let
  inherit (lib) mkDefault mkIf;

  # How many GB of RAM the machine has.
  # TODO: Obtain from system RAM
  ram = 32;

  # Whether to mount / as tmpfs
  tmpfs = true;

  # Whether to use LUKS with interactive unlock
  interactive = true;

  # Use ESP & XBOOTLDR
  xbootldr = true;

  # Use systemd-homed
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/systemd/homed.nix
  #   - Does nothing to setup filesystems
  homed = true;

  # Backend storage mechanism for systemd-homed
  homed-storage = "luks"; # directory | subvolume | fscrypt | cifs | luks
in {
  disko.devices = {
    disk.main = {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # TODO: Handle XBOOTLDR
          boot = {
            size = "1M";
            type = "EF02"; # for grub MBR
            priority = 1;
          };
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["defaults"];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [];
              # if you want to use the key for interactive login be sure there is no trailing newline
              # for example use `echo -n "password" > /tmp/secret.key`
              # passwordFile = mkIf interactive "/tmp/secret.key";
              # passwordFile = config.sops.secrets.fw-user-password.path;
              # additionalKeyFiles = ["/tmp/additionalSecret.key"];
              settings = {
                # keyFile = mkIf (! interactive) "/tmp/secret.key";
                allowDiscards = true;
              };
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };

    # https://github.com/nix-community/disko/blob/master/example/luks-lvm.nix
    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        # nix-store & persistence
        nix = {
          size = "256G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            mountOptions = ["defaults"];
          };
        };

        # TODO: /var
        var = {
          size = "256G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/var";
            mountOptions = ["defaults"];
          };
        };

        # ???
        raw = {
          size = "10M";
        };

        # /home directories
        # systemd-homed LUKS Home Directories:
        # - image contains GPT partition table w/ single partition.
        # - partition must have the type UUID = `773f91ef-66d4-49b5-bd83-d683bf40ad16`
        # - partition must have the label set to the user's username.
        # - partition must contain a LUKS2 volume.
        # - partition LUKS2 volume must contain a LUKS2 token field of type = `systemd-homed`
        #   - JSON data of this token must have a `record` field containing a string w/ base64-encoded data.
        #   - JSON data of this token must have a `iv` field containing a base64-encoded binary initialization vector for the encryption.
        #   - Will be mounted to `~/.identity`
        # - partition LUKS2 volume must be one of these Linux file systems: `ext4`, `btrfs`, `xfs`
        # - partition LUKS2 volume filesystem label must be the user's username
        # - partition LUKS2 volume filesystem should contain a single directory named after the user.
        #
        home = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        };
      };
    };

    nodev.${
      if tmpfs
      then "/"
      else "/tmp"
    } = {
      fsType = "tmpfs";
      mountOptions = [
        "size=${builtins.toString (ram / 8)}G"
        "defaults"
        "mode=755"
      ];
      # then { "/"    = { fsType = "tmpfs"; mountOptions = ["size=${ram / 8}G"]; }; }
      # else { "/tmp" = { fsType = "tmpfs"; mountOptions = ["size=${ram / 8}G"]; }; };
    };
  };

  # TODO: Handle XBOOTLDR
  boot.loader.grub = {
    efiSupport = mkDefault true;
    efiInstallAsRemovable = mkDefault true;
  };

  services = {
    nscd.enable = homed; # Required by:    systemd-homed
    userdbd.enable = homed; # Recommended by: systemd-homed
  };
}
