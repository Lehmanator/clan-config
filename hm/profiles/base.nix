{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      parallel-full             # run commands in parallel, even across machines
      dt                        # duct tape for shell command pipelines
      xe                        # xargs / awk alternative with pattern matching
      uutils-coreutils-noprefix # coreutils rust rewrite
      which                     # locate executables
    ];
    sessionPath = [ "$HOME/.local/bin" ];
    shellAliases = rec {
      b = "bat --plain";
      c = "cat";
      e = "$EDITOR"; v = "$VISUAL";
      ff = "ffmpeg";
      o = "open";
      h = "cd ~";

      # --- Directories ---
      l = "eza --icons";
      ll = l + " -l";
      la = l + " -a";
      lla = ll + " -a";
      lal = lla;
      lt = l + " --tree";
    };
  };
  news.display = "show";
  manual.manpages.enable = true;

  programs = {
    atuin.enable = true;
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch prettybat];
    };
    bottom.enable = true;
    btop.enable = true;
    command-not-found.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = true;
      extraOptions = ["--group-directories-first"];
    };
    fastfetch.enable = true;
    fd.enable = true;
    fzf.enable = true;
    gallery-dl.enable = true;
    gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
    home-manager.enable = true;
    htop.enable = true;
    info.enable = true;
    jq.enable = true;
    k9s.enable = true;
    less.enable = true;
    lesspipe.enable = true;
    lsd.enable = true;
    navi.enable = true;
    pls.enable = true;
    rbw.enable = true;
    readline.enable = true;
    ripgrep.enable = true;
    skim.enable = true;
    starship = {
      enable = true;
      enableTransience = true;
    };
    tealdeer.enable = true;
    thefuck.enable = true;
    topgrade.enable = true;

    # https://github.com/yt-dlp/yt-dlp#configuration
    yt-dlp.enable = true;

    zellij = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    zoxide.enable = true;
  };

  # nixpkgs = {
  #   config = import (inputs.self + /nixpkgs-config.nix);
  #   overlays = [];
  # };
}
