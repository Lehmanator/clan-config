{ config, lib, pkgs
, clan-core
, user
, inputs
, ...
}:
{
  imports = with clan-core.clanModules; [
    inputs.lix-module.nixosModules.default
    inputs.nixos-generators.nixosModules.all-formats

    # --- clanModules ---
    localsend
    sshd
    root-password
    user-password
    static-hosts
    trusted-nix-caches
    ./tailscale.nix
  ];

  clan.core = {
    deployment.requireExplicitUpdate = lib.mkDefault false;
  };

  clan.static-hosts = {
    topLevelDomain = "lehman.run";
    excludeHosts = ["nixos"];
  };
  clan.localsend = {
    enable = true;
    defaultLocation = "/home/${user}/Downloads";
  };

  # After system installed/deployed use:
  # $ clan secrets get {machine_name}-user-password
  clan.user-password = {
    inherit user;
    prompt = true;
  };
  users = {
    groups = {
      admins  = {};
      ${user} = { gid = 1000; };
      users   = { gid = 100; };
    };
    users = let
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2M80EUw0wQaBNutE06VNgSViVot6RL0O6iv2P1ewWH ${user}@fw"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCo3Q3odpbDCcOxKeiqE5YX4sWmSGynXz3Nog0IuQbPfj8/4bCaeQMPMYggu7Txj9Q935teDi0C6mLkeprn5Q0vsZwglX/lAXaMEv3QgnzPzIxple0Ns7buyaIP38JNAHCd6qNMpLXsWU1CrKkX9qOY3CSzb127xMY9IemW2GzIUD8v3SCrmUoEJg3cqZJ3zK21V3SbSyAwf1EJT/jfggksC7gSMOmvkFPJ/8E1L/J7l/+yplS+4cmFoznbVgIyp49Vl6SGE+jay4yc/BAxzmx+x3tPn4zLeZVRswmx6sRZZXY+U+jKeZ5/0HFETtz87rW4cXW95531wpsVufu8M8eqvdOGVIR1a3HYaM82I7Enm95lKXuyoijwYlsVQP+DTWHtzpXNHZekSQjpmlR31pHyF/h7nON2DzCwcdrz+NOvXmQgighXvuwWVF0MmZCHJDJYS4P/RDG2HKztuqxiH5dxYCWyVIcYuS2awHXb+zhOFPi+UvhezgJPMU1gX+djXZGorN87HditBLfFmMckmT1MCU0jzenn4boPE25j5TXRCRCXTI9TMFOgzOS87amE/w8cUFK2WQiIa60SLkNdHy8k4W0aQfjGxEL9ijsB+JKpzgKFOv0EKIBYY8Z4i822RvZ9L7WCDK0BQe0jmkwp0ZUDnST2XY3NMqprVZNHFWKz7w== ${user}@fw"
      ];
    in {
      root.openssh.authorizedKeys.keys = keys;
      ${user} = {
        # uid = 1000;
        group = user;
        isNormalUser = true;
        extraGroups = ["wheel" "admins" "users"]; # "video" "audio" "input" "dialout" "disk" ];
        openssh.authorizedKeys.keys = keys;
      };
    };
  };
  # clan.core.networking.targetHost = "${user}@${config.networking.hostName}";
  #clan.single-disk.device = "/dev/disk/";
  # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # See: https://jade.fyi/blog/finding-functions-in-nixpkgs/
  # TODO: Create separate module/profile for Nix docs
  nix.package = pkgs.lix;
  environment.systemPackages = [
    pkgs.manix    # Util to search Nix docs
    pkgs.nix-doc  # Nix plugin for getting docs on Nix libs
    pkgs.nixdoc   # Gen reference docs for Nix libs
  ];
}
