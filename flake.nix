{
  description = "Personal clan configs.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    nuenv.url = "github:DeterminateSystems/nuenv";
    flake-utils.url = "github:numtide/flake-utils";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, clan-core, flake-utils, lix-module, nuenv, ... }@inputs: let
    debug = true;
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

      # Inventory Docs:
      # - https://docs.clan.lol/guides/inventory/
      # - https://docs.clan.lol/reference/nix-api/inventory/
      # Build API schema: `nix build git+https://git.clan.lol/clan/clan-core#inventory-schema`
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

        # Per-instance: services.<serviceName>.<instanceName>.config
        # Per-role:     services.<serviceName>.<instanceName>.roles.<roleName>.config
        # Per-machine:  services.<serviceName>.<instanceName>.machines.<machineName>.config
        services = {
          # borgbackup.instance_1 = {
          #   roles.server.machines = ["wyse"];
          #   roles.server.tags = ["backup-server"];
          #   roles.client.tags = ["backup"];
          # };
        };
      };
    };
  in (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import clan-core.inputs.nixpkgs { inherit system; overlays = [nuenv.overlays.default]; };
    clanPkgs = clan-core.packages.${system};
    selfPkgs = self.packages.${system};
  in {
    apps = with clanPkgs; rec {
      default    = cli;
      app        = { type="app"; program=clan-app;        meta.description="GTK app to manage your clan";  };
      cli        = { type="app"; program=clan-cli;        meta.description="CLI to manage your clan";      };
      vm-manager = { type="app"; program=clan-vm-manager; meta.description="GTK app to manage clan VMs";   };
      webview-ui = { type="app"; program=clan-webview-ui; meta.description="Web app to manage your clan";  };
    };

    # add the Clan CLI tool to the dev shell
    # TODO: Fix nix develop build hanging
    devShells.default = pkgs.mkShell {
      name = "clan";
      packages = [ 
        pkgs.onefetch
        clanPkgs.clan-app
        clanPkgs.clan-cli
        clanPkgs.clan-vm-manager
        clanPkgs.module-docs
        clanPkgs.editor
        clanPkgs.webview-ui
        selfPkgs.clan-flash
        selfPkgs.clan-installer-instructions
        selfPkgs.clan-module-schema
      ];
      shellHook = ''
        ${lib.getExe pkgs.onefetch} 
        echo "---[Clan: Overview]---"
        ${clanPkgs.clan-cli}/bin/clan show
        echo "---[Clan: Machines]---"
        ${clanPkgs.clan-cli}/bin/clan machines list | xargs -n1 ${clanPkgs.clan-cli}/bin/clan machines show && echo '\n'
      '';
    };
    packages = {
      inherit (clanPkgs) clan-app clan-cli clan-cli-docs clan-ts-api clan-vm-manager;
      clan-codium-editor = clanPkgs.editor;
      clan-webview-ui = clanPkgs.webview-ui;
      clan-installer-instructions = pkgs.callPackage ./packages/installer-instructions.nix {};
      clan-flash                  = pkgs.callPackage ./packages/flasher.nix {
        inherit (clanPkgs) clan-cli;
        clan-input-path = inputs.clan-core.outPath;
      };
      clan-module-docs = clanPkgs.module-docs;
      clan-module-schema = pkgs.writeShellScript "clan-module-schema-preview" ''
        ${lib.getExe pkgs.jq} '.' ${clanPkgs.module-schema} --color-output | ${lib.getExe pkgs.bat} --plain
      '';
    };
  })) // {
    nixosConfigurations = clan.nixosConfigurations // {
      # Inherit installer config from upstream clan-core.
      # TODO: Auto-add SSH keys from other machines.
      inherit (clan-core.nixosConfigurations) flash-installer;
    };
    
  } // lib.optionalAttrs debug {
    inherit (clan) clanInternals;
    inherit inputs;
    lib = lib // clan-core.lib;
  };
}
