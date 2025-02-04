{
  inputs,
  pkgs,
  ...
}: {
  imports = with inputs; [
    nixos-generators.nixosModules.all-formats
    self.nixosProfiles.home-manager
    # self.nixosProfiles.tailscale
  ];

  # See: https://jade.fyi/blog/finding-functions-in-nixpkgs/
  # TODO: Create separate module/profile for Nix docs
  nix = {
    package = pkgs.lix;
    settings.experimental-features = ["nix-command" "flakes" "repl-flake"];
  };
  environment.systemPackages = [
    inputs.clan-core.packages.${pkgs.system}.clan-cli-full
    pkgs.manix # Util to search Nix docs
    pkgs.nix-doc # Nix plugin for getting docs on Nix libs
    pkgs.nixdoc # Gen reference docs for Nix libs
  ];
}
