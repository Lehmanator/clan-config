{ config, lib, pkgs, ... }:
{
  home = {
    sessionVariables.OLLAMA_HOST = "45.42.244.197:11434";
  };

  gtk.gtk3.bookmarks = [
    "file:///${config.home.homeDirectory}/Code/Lehmanator"
  ];
  
}
