{
  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    fenix,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        fenixPackages = fenix.packages.${system};
        rust = fenixPackages.combine [
          (fenixPackages.stable.withComponents [
            "cargo"
            "clippy"
            "rust-src"
            "rustc"
            "rustfmt"
          ])
          fenixPackages.targets.wasm32-unknown-unknown.stable.rust-std
        ];
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            rust
            pkgs.pkg-config
            pkgs.openssl
            pkgs.wasm-pack
          ];
          buildInputs = [
            pkgs.openssl
          ];
        };
      }
    );
}