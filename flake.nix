{
  description = "Personal clan configs.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    nuenv.url = "github:DeterminateSystems/nuenv";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, clan-core, lix-module, nuenv, ... }@inputs: let
    debug = true;
    system = "x86_64-linux";
    pkgs = import clan-core.inputs.nixpkgs { inherit system; overlays = [nuenv.overlays.default]; };
    inherit (clan-core.inputs.nixpkgs) lib;
    
    # Usage:
    # - https://docs.clan.lol
    # - https://docs.clan.lol/reference/nix-api/buildclan/
    clan = clan-core.lib.buildClan {
      directory = self;
      specialArgs = { 
        inherit inputs self;
        user = "sam";
      };

      # Func mapping arch (string) -> instantiated pkgs.
      #  If specified, this nixpkgs only imported once per `system`.
      #  Improves performance, but all nipxkgs.* options will be ignored on hosts.
      pkgsForSystem = system: import clan-core.inputs.nixpkgs {
        inherit system;
        config = {
          allowBroken = false;
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [
          nuenv.overlays.default
        ];
      };

      # Pre-requisite: boot into the installer
      # See: https://docs.clan.lol/getting-started/installer
      # local> mkdir -p ./machines/machine1
      # local> Edit ./machines/machine1/configuration.nix to your liking
      # machines = rec { default = fw; defaultVM = ?;
      machines = {
        # "wyse" will be the hostname of the machine
        wyse = { imports = [ ./modules/shared.nix ./machines/wyse/configuration.nix ]; };
        aio  = { imports = [ ./modules/shared.nix ./machines/aio/configuration.nix  ]; };
        fw   = { imports = [ ./modules/shared.nix ./machines/fw/configuration.nix   ]; };
          # clan.core = {
          #   deployment.requireExplicitUpdate = false;
          #   # machineDescription = "Framework Laptop";
          #   # machineName = "fw";
          #   # machineIcon = ./machines/${host}/icon.svg;
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

      # https://docs.clan.lol/reference/nix-api/inventory/
      inventory = {
        meta = {
          name = "Lehmanator";
          description = "Personal clan configs";
          icon = "https://github.com/Lehmanator/Lehmanator/blob/main/assets/images/profile.png";
        };
        machines = {
          fw = {
            name = "fw";
            description = "Framework Laptop 13";
            icon = "./machines/fw/icon.svg";
            tags = ["backup"];
            system = "x86_64-linux";
          };
          wyse = {
            name = "wyse";
            description = "Dell Wyse Mini Desktop";
            icon = "./machines/wyse/icon.svg";
            tags = ["backup"];
            system = "x86_64-linux";
          };
          aio = {
            name = "aio";
            description = "Dell Inspiron All-in-One Desktop";
            icon = "./machines/aio/icon.svg";
            tags = ["backup"];
            system = "x86_64-linux";
          };
        };
        services = {
          # borgbackup.instance_1 = {
          #   roles.server.machines = ["wyse"];
          #   roles.server.tags = ["backup-server"];
          #   roles.client.tags = ["backup"];
          # };
        };
      };
    };
  in {
    apps.${system} = {
      app = { type = "app"; program = clan-core.packages.${system}.clan-app; };
      cli = { type = "app"; program = clan-core.packages.${system}.clan-cli; };
      vm-manager = { type = "app"; program = clan-core.packages.${system}.clan-vm-manager; };
      webview-ui = { type = "app"; program = clan-core.packages.${system}.clan-webview-ui; };
    };
    nixosConfigurations = clan.nixosConfigurations // {
      # Inherit installer config from upstream clan-core.
      # TODO: Auto-add SSH keys from other machines.
      inherit (inputs.clan-core.nixosConfigurations) flash-installer;
    };

    # add the Clan CLI tool to the dev shell
    devShells.${system}.default = pkgs.mkShell {
      packages = [ 
        clan-core.packages.${system}.clan-cli
        self.packages.${system}.clan-flash
      ];
    };
    packages.${system} = {
      inherit (clan-core.packages.${system}) clan-app clan-cli clan-cli-docs clan-ts-api clan-vm-manager editor module-docs module-schema webview-ui;
      clan-installer-instructions = pkgs.callPackage ./packages/installer-instructions.nix {};
      clan-flash                  = pkgs.callPackage ./packages/flasher.nix {
        inherit (clan-core.packages.${system}) clan-cli;
        clan-input-path = inputs.clan-core.outPath;
      };
    };
  } // lib.optionalAttrs debug {
    inherit (clan) clanInternals;
    inherit inputs pkgs system;
    lib = lib // clan-core.lib;
  };
}
