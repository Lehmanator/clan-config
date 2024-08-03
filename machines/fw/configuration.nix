{ config, user, ... }:
let
  # user = config.networking.hostName;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # Locale service discovery and mDNS
  services.avahi.enable = true;

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  # Disable the default gnome apps to speed up deployment
  services.gnome.core-utilities.enable = false;

  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    inherit user;
    enable = true;
  };

  users.users.${user} = {
    initialPassword = user;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "dialout"
      "disk"
    ];
    uid = 1000;
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };
}
