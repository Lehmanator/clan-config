{inputs, ...}: {
  imports = [];

  # Local service discovery & mDNS
  services.avahi.enable = true;
}
