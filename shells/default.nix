{ pkgs, self, ... }:
let
  inherit (pkgs) lib;
  inherit (self.packages) clan-flash clan-installer-instructions clan-module-schema;
in
{
  # TODO: Fix shell hanging
  default = pkgs.mkShell {
    name = "clan";
    packages = with pkgs; [
      onefetch
      clan-app clan-cli clan-vm-manager
      module-docs
      editor
      webview-ui
      clan-flash clan-installer-instructions clan-module-schema
    ];
    shellHook = ''
      ${lib.getExe pkgs.onefetch} 
      echo "---[Clan: Overview]---"
      ${pkgs.clan-cli}/bin/clan show
      echo "---[Clan: Machines]---"
      ${pkgs.clan-cli}/bin/clan machines list | xargs -n1 ${pkgs.clan-cli}/bin/clan machines show && echo '\n'
    '';
  };
}
