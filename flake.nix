{
  description = "A Nix flake for the Zig programming language";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {nixpkgs, ...}: {
    packages = builtins.mapAttrs (system: pkgs: import ./versions {inherit pkgs;}) nixpkgs.legacyPackages;
  };
}
