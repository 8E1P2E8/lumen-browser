{
  description = "Lumen Browser Nix Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in {
      overlays.default = final: prev: {
        lumen-browser = final.callPackage ./pkgs/by-name/lu/lumen-browser/package.nix {};
      };

      packages.${system} = {
        default = pkgs.lumen-browser;
        lumen-browser = pkgs.lumen-browser;
      };

      apps.${system}.default = {
        type = "app";
        program = "${pkgs.lumen-browser}/bin/lumen-browser";
      };
    };
}
