{
  description = "Personal clan configs.";
  inputs = {
    nixpkgs.follows = "clan-core/nixpkgs";
    flake-parts.follows = "clan-core/flake-parts";

    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";

    nuenv.url = "github:DeterminateSystems/nuenv";
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    clan-core,
    flake-parts,
    haumea,
    nixpkgs,
    ...
  } @ inputs: (flake-parts.lib.mkFlake {inherit inputs self;} ({
    config,
    lib,
    ...
  }: let
    renamePkgs = prefix: lib.mapAttrs' (n: v: lib.nameValuePair "${prefix}${lib.removePrefix prefix n}" v);
  in {
    # Usage:
    # - https://docs.clan.lol
    # - https://docs.clan.lol/reference/nix-api/buildclan/
    debug = true;
    systems = ["x86_64-linux" "aarch64-linux"];
    imports = [
      clan-core.flakeModules.default
      ./hm
      ./nixos
    ];
    clan = {
      inherit self;
      # Share `nixpkgs` between all systems.
      # - Speeds up eval
      # - Removes options: `nixpkgs.*`
      # - Applies config & overlays
      pkgsForSystem = import ./nixpkgs.nix inputs;
      specialArgs = {inherit inputs self;};
      meta.name = "Lehmanator";
      machines = {
        wyse = {imports = [./modules/shared.nix ./machines/wyse/configuration.nix];};
        aio = {imports = [./modules/shared.nix ./machines/aio/configuration.nix];};
        fw = {imports = [./modules/shared.nix ./machines/fw/configuration.nix];};
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
            deploy.targetHost = "root@fw.local";
          };
          wyse = {
            name = "wyse";
            description = "Dell Wyse Mini Desktop";
            icon = "./machines/wyse/icon.svg";
            tags = ["all" "desktop" "backup" "wifi"];
            deploy.targetHost = "root@wyse.local";
          };
          aio = {
            name = "aio";
            description = "Dell Inspiron All-in-One Desktop";
            icon = "./machines/aio/icon.svg";
            tags = ["all" "desktop" "wifi"];
            deploy.targetHost = "root@aio.local";
          };
        };

        services = {
          admin.instance_1.roles.default = {
            tags = ["all"];
            config.allowedKeys = {
              aio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1iVBM368vGUuEWpHoYDwiD6pv8Tq1ZNGMdbD2jedUm sam@aio";
              fw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2M80EUw0wQaBNutE06VNgSViVot6RL0O6iv2P1ewWH sam@fw";
              wyse = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7++n5ihP5vR4zCMcCJVZfwTJYI2LPl7yple9Ga7JZK sam@wyse";
              fajita0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtA7S/6BSsGRTTcKU/9+Aa/VsPCJzNkfjHbvFlaSVKN";
              flame = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEUdU0TtRY9qdnJ/K0P/teEJ5OmTtY+utVkOqLVgh0Y";
              cheetah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoHifjJL0fMBZDjNnXvSDhr0cwgkU80ybVeKRnly7Ku";
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
    perSystem = {
      pkgs,
      system,
      inputs',
      self',
      ...
    }: {
      # Use our custom nixpkgs with overlays and config applied.
      _module.args.pkgs = config.clan.pkgsForSystem system;

      apps = {
        app = {
          type = "app";
          program = self'.packages.clan-app;
          meta.description = "GTK app to manage your clan";
        };
        cli = {
          type = "app";
          program = self'.packages.clan-cli;
          meta.description = "CLI to manage your clan";
        };
        default = {
          type = "app";
          program = self'.packages.clan-cli;
          meta.description = "CLI to manage your clan";
        };
        vm-manager = {
          type = "app";
          program = self'.packages.clan-vm-manager;
          meta.description = "GTK app to manage clan VMs";
        };
        webview-ui = {
          type = "app";
          program = self'.packages.clan-webview-ui;
          meta.description = "Web app to manage your clan";
        };
      };

      devShells = inputs'.clan-core.devShells;
      packages =
        (haumea.lib.load {
          src = ./packages;
          loader = haumea.lib.loaders.callPackage;
          inputs =
            (builtins.removeAttrs pkgs ["root" "self" "super"])
            // inputs'.clan-core.packages
            // {
              flakePath = self.outPath;
            };
        })
        // (renamePkgs "clan-" inputs'.clan-core.packages);
    };

    flake = {
      inherit inputs self;

      # Inherit nixosConfigurations.installer from upstream clan-core.
      # TODO: Auto-add SSH keys from other machines.
      nixosConfigurations.clan-installer = clan-core.nixosConfigurations.flash-installer;
    };
  }));
}
