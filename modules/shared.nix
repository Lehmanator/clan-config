{ inputs, config, lib, pkgs, ... }:
{
  imports = with inputs; [
    lix-module.nixosModules.default
    nixos-generators.nixosModules.all-formats
    ./clanModules-shared.nix
    inputs.self.nixosProfiles.home-manager
    inputs.self.nixosProfiles.tailscale
  ];

  clan.core.deployment.requireExplicitUpdate = lib.mkDefault false;

  # Local service discovery & mDNS
  services.avahi.enable = true;

  # After system installed/deployed use:
  # $ clan secrets get {machine_name}-user-password
  users = {
    groups = {
      admins  = {};
      users   = { gid = 100; };
      ${config.clan.user-password.user} = { gid = 1000; };
    };
    users.${config.clan.user-password.user} = {
      group = config.clan.user-password.user;
      isNormalUser = true;
      extraGroups = ["wheel" "admins" "users"];
      openssh.authorizedKeys.keys = (builtins.attrValues config.clan.admin.allowedKeys) ++ [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCo3Q3odpbDCcOxKeiqE5YX4sWmSGynXz3Nog0IuQbPfj8/4bCaeQMPMYggu7Txj9Q935teDi0C6mLkeprn5Q0vsZwglX/lAXaMEv3QgnzPzIxple0Ns7buyaIP38JNAHCd6qNMpLXsWU1CrKkX9qOY3CSzb127xMY9IemW2GzIUD8v3SCrmUoEJg3cqZJ3zK21V3SbSyAwf1EJT/jfggksC7gSMOmvkFPJ/8E1L/J7l/+yplS+4cmFoznbVgIyp49Vl6SGE+jay4yc/BAxzmx+x3tPn4zLeZVRswmx6sRZZXY+U+jKeZ5/0HFETtz87rW4cXW95531wpsVufu8M8eqvdOGVIR1a3HYaM82I7Enm95lKXuyoijwYlsVQP+DTWHtzpXNHZekSQjpmlR31pHyF/h7nON2DzCwcdrz+NOvXmQgighXvuwWVF0MmZCHJDJYS4P/RDG2HKztuqxiH5dxYCWyVIcYuS2awHXb+zhOFPi+UvhezgJPMU1gX+djXZGorN87HditBLfFmMckmT1MCU0jzenn4boPE25j5TXRCRCXTI9TMFOgzOS87amE/w8cUFK2WQiIa60SLkNdHy8k4W0aQfjGxEL9ijsB+JKpzgKFOv0EKIBYY8Z4i822RvZ9L7WCDK0BQe0jmkwp0ZUDnST2XY3NMqprVZNHFWKz7w== ${config.clan.user-password.user}@fw"
      ];
    };
  };

  # TODO: Map using nixosConfigurations
  programs.ssh.knownHosts = with inputs.self.nixosConfigurations; {
     aio.publicKeyFile =  aio.config.clan.core.facts.services.openssh.public."ssh.id_ed25519.pub".path;
      fw.publicKeyFile =   fw.config.clan.core.facts.services.openssh.public."ssh.id_ed25519.pub".path;
    wyse.publicKeyFile = wyse.config.clan.core.facts.services.openssh.public."ssh.id_ed25519.pub".path;
  };

  # See: https://jade.fyi/blog/finding-functions-in-nixpkgs/
  # TODO: Create separate module/profile for Nix docs
  nix.package = pkgs.lix;
  environment.systemPackages = [
    pkgs.manix    # Util to search Nix docs
    pkgs.nix-doc  # Nix plugin for getting docs on Nix libs
    pkgs.nixdoc   # Gen reference docs for Nix libs
  ];
}
