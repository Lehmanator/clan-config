{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  # Enable profile picture
  home.file.".face" = {
    enable = true;
    # TODO: Handle nix-on-droid non-configurable/read-only username
    source = "${inputs.self}/hm/configs/${config.home.username}/profile.png";
    target = ".face";
  };
}
