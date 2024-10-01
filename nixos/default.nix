{ inputs, ... }: {
  flake = {
    nixosModules = inputs.haumea.lib.load {
      src = ./modules;
      inputs = { inherit inputs; };
      transformer = inputs.haumea.lib.transformers.liftDefault;
    };
    nixosProfiles = inputs.haumea.lib.load {
      src = ./profiles;
      inputs = { inherit inputs; };
      transformer = inputs.haumea.lib.transformers.liftDefault;
    };
    nixosSuites = inputs.haumea.lib.load {
      src = ./suites;
      inputs = { inherit inputs; };
      transformer = inputs.haumea.lib.transformers.liftDefault;
    };
  };
}
