{ pkgs, self, ... }:
let
  inherit (pkgs) lib;
in
{
  inherit (pkgs) clan-app clan-cli clan-cli-docs clan-ts-api clan-vm-manager;
  clan-codium-editor          = pkgs.editor;
  clan-webview-ui             = pkgs.webview-ui;
  clan-installer-instructions = pkgs.callPackage ./installer-instructions.nix {};
  clan-flash                  = pkgs.callPackage ./flasher.nix {clan-input-path=self;};
  clan-module-docs            = pkgs.module-docs;
  clan-module-schema = pkgs.writeShellScript "clan-module-schema-preview" ''
    ${lib.getExe pkgs.jq} '.' ${pkgs.module-schema} --color-output | ${lib.getExe pkgs.bat} --plain
  '';
}
