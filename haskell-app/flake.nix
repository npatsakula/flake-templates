{
#   description = throw "Add description.";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, flake-compat }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        name = "hproject";
        index-state = "2022-09-06T00:00:00Z";
        overlays = [ haskellNix.overlay (final: prev: {
          flakeProject = final.haskell-nix.project' {
            inherit index-state;
            src = ./.;
            compiler-nix-name = "ghc924";
            shell.tools = {
              cabal = { inherit index-state; };
              hlint = { inherit index-state; };
              haskell-language-server = { inherit index-state; };
            };
            shell.buildInputs = with pkgs; [
              openssl.dev
            ];
          };
        }) ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.flakeProject.flake { };
      in flake // {
        packages.default = flake.packages."${name}:exe:${name}".override(self: {
          enableDeadCodeElimination = true;
          dontStrip = false;
        });

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          exePath = "/bin/${name}";
        };

        packages.container = let
          bin = self.packages.${system}.default;
          version = bin.identifier.version;
          name = bin.identifier.name;
        in pkgs.dockerTools.buildLayeredImage {
          name = name;
          tag = version;

          contents = [ bin ];
          created = "now";
        };
      });
}
