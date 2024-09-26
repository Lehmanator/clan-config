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
  };

  outputs = { self, clan-core, flake-utils, nuenv, ... }@inputs: let
    debug = true;
    inherit (clan-core.inputs.nixpkgs) lib;
    mkOverlay = input: (final: prev: input.packages.${prev.stdenv.hostPlatform.system} );
    mkPkgs = system: import clan-core.inputs.nixpkgs {
      inherit system;
      config = {
        allowBroken = false;
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
      overlays = [
        (mkOverlay clan-core)
        nuenv.overlays.default
      ];
    };

    overlays = rec {
      clan    = mkOverlay clan-core;
      self    = mkOverlay self;
      default = self;
    };
    
    # Usage:
    # - https://docs.clan.lol
    # - https://docs.clan.lol/reference/nix-api/buildclan/
    clan = clan-core.lib.buildClan {
      directory = self;
      pkgsForSystem = mkPkgs; # str->pkgs (instantiated for all machines) Improves perf, hosts ignore nipxkgs.* options.
      specialArgs = {
        inherit inputs self;
        user = "sam";
      };

      # NOTE: Machines in `machines/${name}/configuration.nix` will be registered automatically.
      # NOTE: Use any clanModule in inventory & add machines via `roles.default.*`
      # NOTE: All machine declarations merged (buildClan {machines}, inventory.machines)
      # NOTE: clan-app UI only creates machines in inventory.
      # Pre-requisite: boot into the installer
      # See: https://docs.clan.lol/getting-started/installer
      # local> mkdir -p ./machines/machine1
      # local> Edit ./machines/machine1/configuration.nix to your liking
      # machines = rec { default = fw; defaultVM = ?;
      machines = {
        wyse = { imports = [ ./modules/shared.nix ./machines/wyse/configuration.nix ]; };
        aio  = { imports = [ ./modules/shared.nix ./machines/aio/configuration.nix  ]; };
        fw   = { imports = [ ./modules/shared.nix ./machines/fw/configuration.nix   ]; };
          # clan.core = {
          #   # state = {}; # State directories to backup & restore
          #   # tags = ["laptop" "gnome"];
          #   # facts = {
          #   #   publicStore = "in_repo";    # in_repo | vm | custom
          #   #   publicDirectory    = null;  # Dir where public facts are stored
          #   #   secretPathFunction = null;  # Function to use to generate path for a decret.
          #   #   secretStore = "sops"; # sops | password-store | vm | custom
          #   #   secretUploadDirectory = null; # Dir where secrets are uploaded into. This is backend-specific.
          #   #   services.example = {
          #   #     name = "example";
          #   #     generator = {path=[]; prompt="Text for user prompt"; script = "myscript.sh"; };
          #   #     # Public facts to generate for this service
          #   #     public.factName = {
          #   #       name = "example";
          #   #       path = "${config.clan.core.clanDir}/machines/${config.clan.core.machineName}/facts/${fact.config.name}";
          #   #       value = "${config.clan.core.clanDir}/${fact.config.path}";
          #   #     }; 
          #   #     secret.factName = {
          #   #       name = "example";
          #   #       path = "/no-such-path";
          #   #       groups = [];
          #   #     }; 
          #   #   };
          #   # };
          # };
        };

      # Inventory Docs:
      # - https://docs.clan.lol/guides/inventory/
      # - https://docs.clan.lol/reference/nix-api/inventory/
      # Build API schema: `nix build git+https://git.clan.lol/clan/clan-core#inventory-schema`
      inventory = {
        meta = {
          name = "Lehmanator";
          description = "Personal clan configs";
          # icon = "${inputs.self}/icon.png";  
          # icon = ./icon.png;
        };
        machines = {
          fw = {
            name = "fw";
            description = "Framework Laptop 13";
            icon = "./machines/fw/icon.svg";
            tags = ["all" "laptop"];
            system = "x86_64-linux";
            deploy.targetHost = "root@fw.local";
          };
          wyse = {
            name = "wyse";
            description = "Dell Wyse Mini Desktop";
            icon = "./machines/wyse/icon.svg";
            tags = ["all" "desktop" "backup"];
            system = "x86_64-linux";
            deploy.targetHost = "root@wyse.local";
          };
          aio = {
            name = "aio";
            description = "Dell Inspiron All-in-One Desktop";
            icon = "./machines/aio/icon.svg";
            tags = ["all" "desktop"];
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
          localsend.instance_1.roles.default = {
            tags = ["all"];
            config.enable = true;
          };
          machine-id.instance_1.roles.default.tags = ["all"];
          root-password.instance_1.roles.default.tags = ["all"];
          sshd.instance_1.roles.default.tags = ["all"];
          state-version.instance_1.roles.default.tags = ["all"];
          static-hosts.instance_1.roles.default = {
            tags = ["all"];
            config = {
              topLevelDomain = "lehman.run";
              excludeHosts = ["nixos"];
            };
          };
          trusted-nix-caches.instance_1.roles.default.tags = ["all"];
          user-password.instance_1.roles.default = {
            config = { prompt=true; user="sam"; };
            tags = ["all"];
          };
        };
      };
    };
  in (flake-utils.lib.eachDefaultSystem (system: let pkgs = mkPkgs system; in
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
  })) // {
    # Inherit installer config from upstream clan-core.
    # TODO: Auto-add SSH keys from other machines.
    nixosConfigurations = clan.nixosConfigurations // {
      inherit (clan-core.nixosConfigurations) flash-installer;
    };
  } // lib.optionalAttrs debug {
    inherit (clan) clanInternals clanModules flakeModules;
    inherit (clan-core) nixosModules templates;
    inherit inputs;
    inherit overlays;
    lib = lib // {
      clan = clan-core.lib;
      flake-utils = flake-utils.lib;
    };
  };
}
