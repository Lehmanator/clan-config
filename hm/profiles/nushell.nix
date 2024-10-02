{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  programs.carapace.enable = true;
  programs.nushell = {
    enable = true;
    environmentVariables = {
      EDITOR = "hx";
      GIT_EDITOR = "hx";
    };
    shellAliases = rec {
      c = "cat";
      b = "bat --plain";
      e = "hx";
      g = "git";
      ff = "ffmpeg";
      l = "eza --icons";
      ll = "${l} -l";
      la = "${l} -a";
      lla = "${ll} -a";
      lal = "${ll} -a";
      n = "nom";
      o = "open";
    };
  };
}
