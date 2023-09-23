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

Add to existing project:

```bash
# `rust-bin` template:
nix flake init --template github:npatsakula/flake-templates#rust-bin
```

Create new project:

```bash
# `rust-bin` template:
nix flake new --template github:npatsakula/flake-templates#rust-bin ./rusty
# Until we don't have template name replacer:
cd rusty && sd 'rust-bin' 'rusty' Cargo.toml
```
