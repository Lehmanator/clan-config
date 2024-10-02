{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  # home.sessionVariables.SHELL = config.programs.zsh.package + /bin/zsh;
  # home.sessionVariables.SHELL =  "${config.home.homeDirectory}/.nix-profile/bin/zsh";
  home.sessionVariables.SHELL = lib.getExe config.programs.zsh.package;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    package = pkgs.zsh;
    autocd = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#ff00ff,bg=cyan,bold,underline";
      # strategy = ["match_prev_cmd" "completion"];  # Avail: 24.11
    };
    cdpath = [];
    defaultKeymap = "viins";
    dirHashes = {
      docs  = "$HOME/storage/shared/Documents";
      vids  = "$HOME/storage/shared/Videos";
      dl    = "$HOME/storage/shared/Downloads";
    };
    dotDir = ".config/zsh";  # Relative to $HOME
    # Extra commands that should be added to .zshenv.
    # envExtra = ''
    # '';
    history = {
      # append = true;  ## Avail: 24.11
      extended = true;
      ignoreDups = true;
      ignorePatterns = [ "rm *" "pkill *" ];
      ignoreSpace = true;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      save = 100000;
      share = true;
      size = 100000;
    };
    historySubstringSearch = {
      enable = true;
      searchDownKey = [  "^[[B"];  # $terminfo[kcud1]
      searchUpKey   = [  "^[[A"];  # $terminfo[kcuu1]
    };
    # Extra commands that should be added to .zshrc.
    initExtra = ''
      fastfetch  
    '';
    # Extra commands that should be added to .zshrc before compinit.
    # initExtraBeforeCompInit = '''';
    # Commands that should be added to top of .zshrc.
    # initExtraFirst = '''';
    # Extra local variables defined at the top of .zshrc.
    # localVariables = { POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = ["dir" "vcs"]; };
    # loginExtra=""; logoutExtra="";
    # plugins =[
    #   {}
    # ];
    shellGlobalAliases = {
    };
    syntaxHighlighting.enable = true;

    # NOTE: Enables shell profiling. Only should enable when needed.
    zprof.enable = false;

    zsh-abbr = { 
      enable = true;
      abbreviations = {
        g = "git";
        n = "nix";
        mkd = "mkdir -p";
      };
    };
  };
}
