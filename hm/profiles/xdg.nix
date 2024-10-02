{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  home.preferXdgDirectories = true;
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    # TODO: Remap dirs to ~/storage/shared/
    userDirs = {
      enable = false;
    };
  };
}
