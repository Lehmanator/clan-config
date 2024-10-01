{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  imports = with inputs.self.homeProfiles; [
    base
    termux
  ];
}
