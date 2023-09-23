{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    crane = { url = "github:ipetkov/crane"; inputs.nixpkgs.follows = "nixpkgs"; };
    advisory-db = { url = "github:rustsec/advisory-db"; flake = false; };
  };

  outputs = { self, nixpkgs, utils, crane, rust-overlay, advisory-db, flake-compat }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ rust-overlay.overlays.default ];
        }).extend(self: super: {
          rust_stable = self.rust-bin.stable.latest.default;
          rust_nightly = self.rust-bin.nightly.latest.default;
        });

        stdenv = pkgs.llvmPackages_16.stdenv;
        mkShell = pkgs.mkShell.override { inherit stdenv; };
        crane' = (crane.mkLib pkgs).overrideToolchain (pkgs.rust_stable);

        lalrpopFilter = path: _type: builtins.match ".*lalrpop$" path != null;
        testDataFilter = path: _type: builtins.match ".*testdata$" path != null;
        sourceFilter = path: type: (lalrpopFilter path type)
          || (testDataFilter path type)
          || (crane'.filterCargoSources path type);

        src = pkgs.lib.cleanSourceWith { src = ./.; filter = sourceFilter; };
        nativeBuildInputs = with pkgs; [ gperftools ];
        commonArgs = { inherit src nativeBuildInputs; };

        cargoArtifacts = crane'.buildDepsOnly (commonArgs // {});
        name = "${cargoArtifacts.pname}";
      in rec {
        packages = {
          default = packages."${name}";

          "${cargoArtifacts.pname}" = crane'.buildPackage (commonArgs // {
            inherit cargoArtifacts;
          });

          container = let
            rev = self.sourceInfo.shortRev or "dirty";
            tag = "${packages."${name}".version}-${rev}";
          in pkgs.dockerTools.buildLayeredImage {
            inherit tag name;
            contents = [ packages."${name}" ];
            created = "now";
          };
        };
        checks = {
          clippy = crane'.cargoClippy (commonArgs // {
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          });

          test = crane'.cargoNextest (commonArgs // {
            inherit cargoArtifacts;
          });

          audit = crane'.cargoAudit {
            inherit src advisory-db;
          };

          format = crane'.cargoFmt { inherit src; };
        };

        devShells = rec {
          stable = mkShell {
            packages = (with pkgs; [ rust_stable cargo-outdated git ])
              ++ nativeBuildInputs;
          };

          nightly = mkShell {
            packages = (with pkgs; [ rust_stable cargo-outdated git ])
              ++ nativeBuildInputs
              ++ [ pkgs.cargo-udeps ];
          };
          
          default = stable;
        } ;
      });
}
