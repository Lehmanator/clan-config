{
  description = "Personal clan configs.";
  inputs = {
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    nixpkgs.follows = "clan-core/nixpkgs";
    nuenv.url = "github:DeterminateSystems/nuenv";
    flake-utils.url = "github:numtide/flake-utils";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, clan-core, flake-utils, haumea, home-manager, nixpkgs, nuenv, ... }@inputs: let
    debug = true;
    nixpkgsConfig = {
      allowBroken = false;
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
    nixpkgsOverlays = [
      (lib.mkOverlay clan-core)
      nuenv.overlays.default
    ];
    lib =  nixpkgs.lib //
       flake-utils.lib //
            haumea.lib //
      home-manager.lib //
      { clan = clan-core.lib;
        mkOverlay = input: (final: prev: input.packages.${prev.stdenv.hostPlatform.system} );
        mkPkgs = system: import nixpkgs { inherit system; config=nixpkgsConfig; overlays=nixpkgsOverlays; };
        mkConfigComponent = { 
          configType       ? "eval",
          configDirectory  ? "eval",
          configLib        ? lib.evalModules,
          specialArgsName  ? "extraSpecialArgs",
          extraSpecialArgs ? {},
          extraArgs        ? {},
          extraModules     ? [],
        }: let mkLoader = c: inputs.haumea.lib.load {
            inputs = { inherit inputs; };
            transformer = inputs.haumea.lib.transformers.liftDefault;
            src = "${inputs.self}/${configDirectory}/${inputs.nixpkgs.lib.strings.toLower (if c=="Configurations" then "configs" else c)}";
          };
        in inputs.nixpkgs.lib.attrsets.mapAttrs' (n: v: lib.nameValuePair "${configType}${n}" v) (rec {
          Modules           = mkLoader "modules";
          Profiles          = mkLoader "profiles";
          Suites            = mkLoader "suites";
          ConfigurationsRaw = mkLoader "configs";
          ConfigurationsAttrs = builtins.mapAttrs (_: cfg: extraArgs // {
            "${specialArgsName}" = { inherit inputs; } // extraSpecialArgs;
            modules = [cfg] ++ extraModules;
          }) ConfigurationsRaw;
          Configurations = builtins.mapAttrs (_: cfg: configLib ({
            "${specialArgsName}" = { inherit inputs; } // extraSpecialArgs;
            modules = [cfg] ++ extraModules;
          } // extraArgs)) ConfigurationsRaw;
        });
    };
    pkgs = lib.eachDefaultSystem lib.mkPkgs;
    overlays = rec {
      clan    = lib.mkOverlay clan-core;
      self    = lib.mkOverlay self;
      default = self;
    };

    # Usage:
    # - https://docs.clan.lol
    # - https://docs.clan.lol/reference/nix-api/buildclan/
    clan = lib.clan.buildClan {
      directory = self;
      pkgsForSystem = lib.mkPkgs;
      specialArgs = { inherit inputs; };
      machines = {
        wyse = { imports = [ ./modules/shared.nix ./machines/wyse/configuration.nix ]; };
        aio  = { imports = [ ./modules/shared.nix ./machines/aio/configuration.nix  ]; };
        fw   = { imports = [ ./modules/shared.nix ./machines/fw/configuration.nix   ]; };
      };

      # Inventory Docs:
      # - https://docs.clan.lol/guides/inventory/
      # - https://docs.clan.lol/reference/nix-api/inventory/
      # Build API schema: `nix build git+https://git.clan.lol/clan/clan-core#inventory-schema`
      inventory = {
        meta = {
          name = "Lehmanator";
          description = "Personal clan configs";
          # icon = "./icon.png";
        };
        machines = {
          fw = {
            name = "fw";
            description = "Framework Laptop 13";
            icon = "./machines/fw/icon.svg";
            tags = ["all" "laptop" "wifi"];
            system = "x86_64-linux";
            deploy.targetHost = "root@fw.local";
          };
          wyse = {
            name = "wyse";
            description = "Dell Wyse Mini Desktop";
            icon = "./machines/wyse/icon.svg";
            tags = ["all" "desktop" "backup" "wifi"];
            system = "x86_64-linux";
            deploy.targetHost = "root@wyse.local";
          };
          aio = {
            name = "aio";
            description = "Dell Inspiron All-in-One Desktop";
            icon = "./machines/aio/icon.svg";
            tags = ["all" "desktop" "wifi"];
            system = "x86_64-linux";
            deploy.targetHost = "root@aio.local";
          };
        };

        services = {
          admin.instance_1 = { 
            roles.default = {
              tags = ["all"];
              config.allowedKeys = {
                aio     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1iVBM368vGUuEWpHoYDwiD6pv8Tq1ZNGMdbD2jedUm sam@aio";
                fw      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2M80EUw0wQaBNutE06VNgSViVot6RL0O6iv2P1ewWH sam@fw";
                wyse    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7++n5ihP5vR4zCMcCJVZfwTJYI2LPl7yple9Ga7JZK sam@wyse";
                fajita0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtA7S/6BSsGRTTcKU/9+Aa/VsPCJzNkfjHbvFlaSVKN";
                flame   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEUdU0TtRY9qdnJ/K0P/teEJ5OmTtY+utVkOqLVgh0Y";
                cheetah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoHifjJL0fMBZDjNnXvSDhr0cwgkU80ybVeKRnly7Ku";
              };
            };
          };
          disk-id.instance_1.roles.default.tags = ["all"];
          iwd.instance_1.roles.default = {
            tags = ["wifi"];
            config.networks = {
              home.ssid = "Lehman"; 
              hotspot.ssid = "hotspot-cheetah";
            };
          };
          machine-id.instance_1.roles.default.tags = ["all"];
          state-version.instance_1.roles.default.tags = ["all"];
        };
      };
    };
  in (lib.eachDefaultSystem (system: let pkgs = lib.mkPkgs system; in
  {
    devShells = import ./shells   { inherit pkgs self; };
    packages  = import ./packages { inherit pkgs self; };
    apps = rec {
      default    = cli;
      app        = { type="app"; program=pkgs.clan-app;        meta.description="GTK app to manage your clan";  };
      cli        = { type="app"; program=pkgs.clan-cli;        meta.description="CLI to manage your clan";      };
      vm-manager = { type="app"; program=pkgs.clan-vm-manager; meta.description="GTK app to manage clan VMs";   };
      webview-ui = { type="app"; program=pkgs.clan-webview-ui; meta.description="Web app to manage your clan";  };
    };
  }))
  // (lib.optionalAttrs debug {
    inherit (clan) clanInternals;
    inherit (clan.clanInternals) clanModules;
    inherit (clan-core) flakeModules templates;
    inherit inputs;
    inherit 
      lib
      overlays
    ;
  })
  // (lib.mkConfigComponent {
    configType      = "home";
    configDirectory = "hm";
    configLib       = inputs.home-manager.lib.homeManagerConfiguration;
    specialArgsName = "extraSpecialArgs";
    extraModules    = [{
      home = lib.mkDefault (rec {
        stateVersion  = "24.11";
        username      = "sam";
        homeDirectory = "/home/${username}";
      });
    }];
    extraArgs = {
      inherit lib;
      pkgs = import inputs.nixpkgs { config = nixpkgsConfig; overlays = nixpkgsOverlays; };
    };
  })
  // (lib.mkConfigComponent {
      configType      = "nixos";
      configLib       = inputs.nixpkgs.lib.nixosSystem;
      configDirectory = "nixos";
      specialArgsName = "specialArgs";
    })
  # // (lib.mkConfigComponent {
  #   configType       = "nixOnDroid";
  #   configLib        = inputs.nix-on-droid.lib.nixOnDroidConfiguration;
  #   configDirectory  = "nod";
  #   specialArgsName  = "extraSpecialArgs";
  #   extraArgs        = {
  #     home-manager-path = inputs.home-manager.outPath;
  #     pkgs = import inputs.nixpkgs { config = nixpkgsConfig; overlays = nixpkgsOverlays; };
  #   };
  # })
  // {
    # Inherit installer config from upstream clan-core.
    # TODO: Auto-add SSH keys from other machines.
    inherit (clan-core) nixosModules;
    nixosConfigurations = clan.nixosConfigurations // {
      inherit (clan-core.nixosConfigurations) flash-installer;
    };
  } 
  ;
}
