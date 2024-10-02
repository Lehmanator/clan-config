{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "adwaita-dark";
      editor.line-number = "relative";
    };
  };
  home.sessionVariables.EDITOR = "hx";
}
