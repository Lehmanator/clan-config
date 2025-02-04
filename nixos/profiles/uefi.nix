{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.self.nixosProfiles.plymouth
    # (inputs.self + "/machines/" + config.networking.hostName + "/disko.nix")
  ];

  services.fwupd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 7172;
      authorizedKeys = builtins.attrValues config.clan.admin.allowedKeys;
      hostKeys = ["/var/lib/initrd-ssh-key"];
    };
  };
  boot.initrd.availableKernelModules = ["xhci_pci"];
}
