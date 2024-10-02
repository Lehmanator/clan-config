{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    forwardAgent = false;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
        identityFile = ["~/.ssh/id_ed25519"];
        extraOptions.VisualHostKey = "no";
      };
    };
  };
}
