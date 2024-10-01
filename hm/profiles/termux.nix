{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  home = {
    homeDirectory = "/data/data/com.termux.nix/files/home";
    sessionVariables = {
      # TODO: How to open in Android browser
      # BROWSER = "";
      VISUAL = "termux-open";
    };
  };

  # xdg.configFile."nixpkgs/config.nix".source = inputs.self + /nixpkgs-config.nix;

}
