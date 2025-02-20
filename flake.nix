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
          aio = {
            name = "aio";
            description = "Dell Inspiron All-in-One Desktop";
            icon = ./machines/aio/icon.svg;
            tags = ["all" "desktop" "hdd" "server" "wifi"];
            deploy.targetHost = "root@aio.local";
          };
          fw = {
            name = "fw";
            description = "Framework Laptop 13";
            icon = ./machines/fw/icon.svg;
            tags = ["all" "laptop" "nvme" "wifi"];
            deploy.targetHost = "root@fw.local";
          };
          wyse = {
            name = "wyse";
            description = "Dell Wyse Mini Desktop";
            icon = ./machines/wyse/icon.svg;
            tags = ["all" "backup" "desktop" "server" "nvme" "wifi"];
            deploy.targetHost = "root@wyse.local";
          };
        };

        services = {
          admin.sam.roles.default = {
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
          disk-id.default.roles.default.tags = ["all"];
          importer = {
            base.roles.default = {
              tags = ["all"];
              extraModules = [
                "nixos/suites/base.nix"
                "nixos/profiles/uefi.nix"
                "modules/shared.nix"
              ];
            };
            gnome.roles.default = {
              tags = ["desktop" "laptop"];
              extraModules = ["nixos/profiles/gnome.nix"];
            };
            server.roles.default = {
              tags = ["server"];
              extraModules = ["nixos/suites/server.nix"];
            };
          };
          iwd.default.roles.default = {
            tags = ["wifi"];
            config.networks = {
              home.ssid = "Lehman";
              hotspot.ssid = "hotspot-cheetah";
            };
          };
          machine-id.default.roles.default.tags = ["all"];
          root-password.default.roles.default.tags = ["all"];
          single-disk = {
            hdd.roles.default = {
              tags = ["hdd"];
              config.device = "/dev/hda";
            };
            nvme.roles.default = {
              tags = ["nvme"];
              config.device = "/dev/nvme0n1";
            };
          };
          sshd.default.roles = {
            client = {
              tags = ["all"];
              config.certificate.searchDomains = ["lehman.run"];
            };
            server = {
              tags = ["all"];
              config = {
                certificate.searchDomains = ["lehman.run"];
                hostKeys.rsa.enable = true;
              };
            };
          };
          state-version.default.roles.default.tags = ["all"];
          user-password.sam.roles.default = {
            tags = ["all"];
            config.user = "sam";
          };
          zerotier.default = {
            roles = {
              controller.machines = ["wyse"];
              peer = {
                tags = ["all"];
                config = {
                  excludeHosts = ["nixos"];
                  networkIds = [];
                  networkIps = [
                    "192.168.1.2"
                    "192.168.1.30"
                  ];
                };
              };
              moon = {
                tags = ["server"];
                # Make this machine a moon.
                # Other machines can join this moon by adding this moon in their config.
                config.moon.stableEndpoints = ["1.2.3.4" "10.0.0.3/9993" "2001:abcd:abcd::3/9993"];
              };
            };
            extraModules = [
              "modules/zerotier.nix"
            ];
          };
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
