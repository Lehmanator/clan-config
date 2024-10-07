{ inputs, self, config, lib, ... }: {

  # https://flake.parts/options/devshell
  imports = [inputs.devshell.flakeModule];

  # TODO: Test if loaded config is derivation or attrs
  # TODO: devShells = inputs.haumea.lib.load {}; # Regular mkShell derivations
  # TODO: devshells = inputs.haumea.lib.load {}; # devshell.flakeModule configs 
  # TODO: Exclude self (./shells/default.nix)
  perSystem = { pkgs, system, inputs', self', ... }: {
    # devshells = inputs.haumea.lib.load {
    #   src = ./configs;
    #   loader = inputs.haumea.lib.loaders.default;
    #   transformer = inputs.haumea.lib.transformers.liftDefault;
    #   inputs = { inherit inputs inputs'; };
    # };

    # devShells = inputs.haumea.lib.load {
    #   src = ./packages;
    #   loader = inputs.haumea.lib.loaders.callPackage;
    #   transformer = inputs.haumea.lib.transformers.liftDefault;
    #   inputs = pkgs // {
    #   };
    # };
  };
}

# { lib
# , mkShell
# , onefetch
# , clan-app
# , clan-cli
# , clan-vm-manager
# , clan-module-docs
# , clan-editor
# , clan-webview-ui
# , ...
# }:
# # let
# #   inherit (self.packages) clan-flash clan-installer-instructions clan-module-schema;
# # in
# {
#   # TODO: Fix shell hanging
#   default = mkShell {
#     name = "clan";
#     packages = [
#       onefetch
#       clan-app clan-cli clan-vm-manager
#       clan-module-docs
#       clan-editor
#       clan-webview-ui
#       # clan-flash
#       # clan-installer-instructions
#       # clan-module-schema
#     ];
#     shellHook = ''
#       ${lib.getExe onefetch} 
#       echo "---[Clan: Overview]---"
#       ${clan-cli}/bin/clan show
#       echo "---[Clan: Machines]---"
#       ${clan-cli}/bin/clan machines list | xargs -n1 ${clan-cli}/bin/clan machines show && echo '\n'
#     '';
#   };
# }
