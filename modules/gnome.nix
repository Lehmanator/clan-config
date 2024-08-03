{ config, lib, pkgs, user, ... }:
let
  inherit (lib) mkDefault mkIf;
in
{
  clan.tags = ["gnome" "desktop"];
  services = {
    displayManager.autoLogin = { 
      inherit user;
      enable = mkDefault false;
    };
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = mkDefault true;
    };

    gnome = {
      # Disable the default gnome apps to speed up deployment
      core-utilities.enable = true;
      core-developer-tools.enable = true;
      tracker-miners.enable = true;
      tracker.enable = true;
    };
    sysprof.enable = true;
    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  };

  systemd.services = mkIf config.services.displayManager.autoLogin.enable {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  users.users.${user}.extraGroups = ["gdm" "networkmanager"];
  programs.dconf = {
    enable = true;
    # profiles.user.databases = [{settings = {"org/gnome/desktop/interface".clock-show-weekday=true;};}];
  };
  environment.systemPackages = [
    pkgs.adwaita-icon-theme
    pkgs.gnomeExtensions.appindicator
  ];
  
  # Declarative Profile Picture
  # TODO: Use path relative to config.clan.core.clanDir
  system.activationScripts.script.text = let
    profile-pic = ../icon.png;
    #cp /home/${user}/PATH-TO/.face /var/lib/AccountsService/icons/${user}
  in ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp ${profile-pic} /var/lib/AccountsService/icons/${user}
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${user}\n" > /var/lib/AccountsService/users/${user}

    chown root:root /var/lib/AccountsService/users/${user}
    chmod      0600 /var/lib/AccountsService/users/${user}

    chown root:root /var/lib/AccountsService/icons/${user}
    chmod      0444 /var/lib/AccountsService/icons/${user}
'';

}