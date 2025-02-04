{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  services = {
    displayManager.autoLogin = {
      inherit (config.clan.user-password) user;
      enable = lib.mkDefault false;
    };
    flatpak.enable = true;
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = lib.mkDefault true;
    };

    gnome = {
      # Disable the default gnome apps to speed up deployment
      core-utilities.enable = true;
      core-developer-tools.enable = true;
      tracker-miners.enable = true;
      tracker.enable = true;
    };
    sysprof.enable = true;
    udev.packages = [pkgs.gnome-settings-daemon];
  };

  systemd.services = lib.mkIf config.services.displayManager.autoLogin.enable {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  users.users.${config.clan.user-password.user}.extraGroups = ["gdm" "networkmanager"];
  programs.dconf = {
    enable = true;
    # profiles.user.databases = [{settings = {"org/gnome/desktop/interface".clock-show-weekday=true;};}];
  };
  environment.systemPackages = [
    pkgs.adwaita-icon-theme
    pkgs.gnome-tweaks
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.valent
    pkgs.valent
  ];
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  # Declarative Profile Picture
  # TODO: Use path relative to config.clan.core.settings.directory
  system.activationScripts.script.text = let
    profile-pic = inputs.self + /icon.png;
    #cp /home/${user}/PATH-TO/.face /var/lib/AccountsService/icons/${user}
  in ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp ${profile-pic} /var/lib/AccountsService/icons/${config.clan.user-password.user}
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${config.clan.user-password.user}\n" > /var/lib/AccountsService/users/${config.clan.user-password.user}

    chown root:root /var/lib/AccountsService/users/${config.clan.user-password.user}
    chmod      0600 /var/lib/AccountsService/users/${config.clan.user-password.user}

    chown root:root /var/lib/AccountsService/icons/${config.clan.user-password.user}
    chmod      0444 /var/lib/AccountsService/icons/${config.clan.user-password.user}
  '';
}
