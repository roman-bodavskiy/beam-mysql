{
  inputs = {
    common.url = "github:nammayatri/common?ref=ghc-98-upgrade";
    nixpkgs.follows = "common/nixpkgs";
    flake-parts.follows = "common/flake-parts";
    haskell-flake.follows = "common/haskell-flake";

    bytestring-lexing.url = "github:juspay/bytestring-lexing";
    bytestring-lexing.flake = false;

    mysql-haskell.url = "github:roman-bodavskiy/mysql-haskell?ref=ghc-98-upgrade";
    mysql-haskell.inputs.nixpkgs.follows = "nixpkgs";
    mysql-haskell.inputs.haskell-flake.follows = "haskell-flake";

    beam.url = "github:nammayatri/beam?ref=ghc-98-upgrade";
    beam.inputs.haskell-flake.follows = "haskell-flake";
    beam.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.common.flakeModules.ghc98
        inputs.haskell-flake.flakeModule
      ];
      perSystem = { self', pkgs, lib, config, ... }: {
        haskellProjects.default = {
          projectFlakeName = "beam-mysql";
          basePackages = config.haskellProjects.ghc98.outputs.finalPackages;
          imports = [
            inputs.beam.haskellFlakeProjectModules.output
            inputs.mysql-haskell.haskellFlakeProjectModules.output
          ];

          packages = {
            bytestring-lexing.source = inputs.bytestring-lexing;
          };

          settings = {

            bytestring-lexing = {
              jailbreak = true;
            };

            mysql-haskell = {
             check = false;
            };

            beam-mysql = {
              jailbreak = true;
            };

          };
          autoWire = [ "packages" "checks" "devShells" "apps"];
        };
      };
    });
}
