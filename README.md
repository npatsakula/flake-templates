# Nix templates

## Features

- [x] Rust
  - [x] [rust-overlay](https://github.com/oxalica/rust-overlay) compiler version selector.
  - [x] Development environment: rust, [rust-analyzer](https://github.com/rust-lang/rust-analyzer), [cargo-outdated](https://github.com/kbknapp/cargo-outdated) and [cargo-udeps](https://github.com/est31/cargo-udeps) for nightly compiler.
  - [x] Docker container build via NIX [dockerTools](https://ryantm.github.io/nixpkgs/builders/images/dockertools/).
  - [x] NIX checks: `cargo fmt`, `cargo clippy`, `cargo audit` and `cargo nextest`.
  - [ ] Pre-defined CI pipelines:
    - [ ] GitHub.
    - [ ] GitLab.
- [x] Haskell.
  - [x] Fine-tuned cabal config: extra warning and optimization flags, pre-defined extenstion and dependencies.
  - [x] Development environment: cabal, latest GHC and haskell-language-server.
  - [ ] Pre-defined CI pipelines:
    - [ ] GitHub.
    - [ ] GitLab.

## Pre-requirements

```bash
# Install nix:
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# Create NIX config directory:
mkdir -p ~/.config/nix
# Add flake support:
echo "experimental-features = flakes nix-command" >> ~/.config/nix/nix.conf 
```

## Usage

### Add to existing project

```bash
# `rust-bin` template:
nix flake init --template github:npatsakula/flake-templates#rust-bin
```

### Create new project

```bash
# `rust-bin` template:
nix flake new --template github:npatsakula/flake-templates#rust-bin ./rusty
# Until we don't have template name replacer:
cd rusty && sd 'rust-bin' 'rusty' Cargo.toml
```

### Run checks

```bash
nix flake check -j$(nproc)
```

### Build docker image

**NB!** Currently only for `rust-bin`.

```bash
# Build image:
nix build -j$(nproc) '.#container'
# Import image:
docker build < result
```

Image will contain only (!) executable app and some minimal runtime (coreutils is
not included).

You can add some native dependencies by extending `contents` section:

```nix
contents = [ packages."${name}" pkgs.coreutils-full ];
```

### Specify native dependencies

**NB!** You can search dependencies with [nixpkg](https://search.nixos.org/packages).

Add dependencies in `nativeBuildInputs` list:

```nix
nativeBuildInputs = with pkgs; [ zstd.dev mimalloc.dev pkg-config ];
```

### Use unstable nixpkgs

Replace `nixpkgs` in `input` section:

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
```
