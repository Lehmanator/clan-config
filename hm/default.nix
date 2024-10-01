{ inputs, config, ... }:
let
  inherit (inputs.nixpkgs) lib;
  mkComponents = {
    configType ? "eval",
    configDirectory ? "eval",
    configLib ? inputs.nixpkgs.lib.evalModules,
    specialArgsName ? "extraSpecialArgs",
    extraSpecialArgs ? [],
    extraArgs ? [],
    extraModules ? [],
  }:
  let
    mkLoader = c: inputs.haumea.lib.load {
      inputs = { inherit inputs; };
      transformer = inputs.haumea.lib.transformers.liftDefault;
      src = "${inputs.self}/${configDirectory}/${lib.strings.toLower (if c=="Configurations" then "configs" else c)}";
    };
  in lib.attrsets.mapAttrs' (n: v: lib.nameValuePair "${configType}${n}" v) (rec {
    Modules = mkLoader "modules";
    Profiles = mkLoader "profiles";
    Suites = mkLoader "suites";
    ConfigurationsRaw = mkLoader "configs";
    ConfigurationsAttrs = builtins.mapAttrs (_: cfg: extraArgs // {
      "${specialArgsName}" = {inherit inputs;} // extraSpecialArgs;
      modules = [cfg] ++ extraModules;
    }) ConfigurationsRaw;
    Configurations = builtins.mapAttrs (_: cfg: configLib ({
      "${specialArgsName}" = { inherit inputs; } // extraSpecialArgs;
      modules = [cfg] ++ extraModules;
    } // extraArgs)) ConfigurationsRaw;
  });
  mkHM = mkComponents {
    configType = "home";
    configDirectory = "hm";
    configLib = inputs.home-manager.lib.homeManagerConfiguration;
    specialArgsName = "extraSpecialArgs";
    extraArgs = {
      inherit (inputs.nixpkgs) lib;
      pkgs = config.clan.pkgsForSystem;
      
    };
    extraModules = [{
      home = inputs.nixpkgs.lib.mkDefault {
        stateVersion = "24.11";
        username = "sam";
        homeDirectory = "/home/sam";
      };
    }];
  };
in
{
  flake = {
    homeModules = inputs.haumea.lib.load {
      src = ./modules;
      inputs = { inherit inputs; };
      transformer = inputs.haumea.lib.transformers.liftDefault;
    };
    homeProfiles = inputs.haumea.lib.load {
      src = ./profiles;
      inputs = { inherit inputs; };
      transformer = inputs.haumea.lib.transformers.liftDefault;
    };
    homeSuites = inputs.haumea.lib.load {
      src = ./suites;
      inputs = { inherit inputs; };
      transformer = inputs.haumea.lib.transformers.liftDefault;
    };
  };
}
