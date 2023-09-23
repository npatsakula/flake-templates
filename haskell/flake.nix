{
  inputs = {
    nixpkgs.url = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };
  outputs = { self, utils, nixpkgs, flake-compat }: utils.lib.eachDefaultSystem (system:
  let
    name = "hproject";
    pkgs = import nixpkgs { inherit system; };
    haskellPackages = pkgs.haskell.packages.ghc962;
  in
    {
      packages = rec {
        default = hproject;
        hproject = haskellPackages.callCabal2nix name ./. {};

        container = let
          version = self.packages.${system}.${name}.version;
        in pkgs.dockerTools.buildLayeredImage {
          inherit name;
          tag = "${version}-${self.sourceInfo.shortRev or "dirty"}";

          contents = [ default ];
          created = "now";
        };
      };

      devShells.default = haskellPackages.shellFor {
        packages = p: [ self.packages.${system}.hproject ];
        withHoogle = true;
        buildInputs = with haskellPackages; [
          haskell-language-server
          ghcid
          cabal-install
        ];
      };
  });
}