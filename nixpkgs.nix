{ nixpkgs
, nuenv
, ...
}:
system:
import nixpkgs {
  inherit system;
  overlays = [
    nuenv.overlays.default
  ];
  config = {
    allowBroken = false;
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };
}
