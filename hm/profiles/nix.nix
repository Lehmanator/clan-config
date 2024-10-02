{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  nix = {
    package = pkgs.lix;
    checkConfig = true;
    gc = {
      automatic = true;
      frequency = "weekly";
      # options = "--max-freed $((64 * 1024**3))";
      # persistent = true;  # 24.11
    };
    # keepOldNixPath = true;  # 24.11
    # nixPath = [
    #   "$HOME/.nix-defexpr/channels"
    #   "home-manager-config=$HOME/.config/nix-on-droid/home.nix"
    #   "system-manager-config=$HOME/.config/nix-on-droid/system-manager.nix"
    #   "nix-on-droid-config=$HOME/.config/nix-on-droid/nix-on-droid.nix"
    # ];
    # registry = {};
    settings = {
      # use-sandbox = true;
      show-trace = true;
    };
  };
  
  home.packages = with pkgs; [
    nix-fast-build
    nix-init
    nix-output-monitor
    manix
  ];
  home.shellAliases = rec {
    nos = "nix-on-droid switch --flake ~/.config/nix-on-droid";
    nup = "nix flake update";
    flake = "nix flake";
    show = "nix flake show";
    n = "nom";
  };
}
