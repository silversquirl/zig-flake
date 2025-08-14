{
  description = "A Nix flake for the Zig programming language";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {
    self,
    nixpkgs,
  }: {
    packages =
      builtins.mapAttrs (
        system: pkgs:
          import ./versions {inherit pkgs;}
          // {default = self.packages.${system}.zig;}
      )
      nixpkgs.legacyPackages;
  };
}
