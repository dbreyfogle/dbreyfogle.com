{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        gems = pkgs.bundlerEnv {
          name = "gems";
          ruby = pkgs.ruby;
          gemdir = ./.;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.bundix
            gems
          ];
        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "site";
          src = ./.;
          buildInputs = [ gems ];
          buildPhase = ''
            ${gems}/bin/jekyll build
          '';
          installPhase = ''
            mkdir -p $out
            cp -r _site $out/_site
          '';
        };
      }
    );
}
