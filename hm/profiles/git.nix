{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userEmail = "github@samlehman.dev";
    userName = "Sam Lehman";
    lfs.enable = true;
    difftastic.enable = true;
    aliases = {
      a = "add";
      cm = "commit -m";
      ch = "checkout";
      cl = "clone";
      f = "fetch";
      l = "log --oneline --stat --graph";
      p = "push";
      rb = "rebase";
      s = "status";
    };
    extraConfig = {
      init.defaultBranch = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
      status.submoduleSummary = true;
    };
  };
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
      hosts = ["https://github.com" "https://gist.github.com"];
    };
    extensions = with pkgs; [gh-eco];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      editor = "hx";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
  programs.gh-dash = {
    enable = true;
    settings = {};
  };

  # https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
  programs.lazygit.enable = true;

  # --- Shell Aliases ----------------------------
  programs.nushell.shellAliases.g = "git";
  # programs.zsh.shellGlobalAliases.g = "git";
  # programs.zsh.shellAliases.g = "git";
  programs.zsh.zsh-abbr.abbreviations.g = "git";


  home = {
    sessionVariables.GIT_EDITOR = config.home.sessionVariables.EDITOR;
    shellAliases.g = "git";
  };

  
}
