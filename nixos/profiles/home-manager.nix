{ inputs, config, lib, pkgs, ... }:
let
  inherit (lib) optionals;
in
{
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;

    extraSpecialArgs = {
      inherit inputs;
      user = config.clan.user-password.user;
      # clanDir = config.clan.core.clanDir;
    };

    sharedModules = [
      # nixos:
      # clan: 
      # common: 
      # inputs.sops-nix.homeManagerModules.sops
    ]
      # ++ optionals config.services.desktopManager.gnome.enable []
      # ++ optional config.services.flatpak.enable inputs.nix-flatpak.hmModules.nix-flatpak
    ;

    # users = {
    #   "${config.clan.user-password.user}" = inputs.self.homeConfigurations.${config.clan.user-password.user}.config;
    # };

  };
}
