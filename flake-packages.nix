{
  nixpkgs,
  stableName,
  nightlyName,
}: let
  inherit (nixpkgs) lib;

  stable = import ./releases/stable.nix;
  nightly = import ./releases/nightly.nix;

  name = namer: value: {
    inherit value;
    name = namer value;
  };

  releases =
    builtins.listToAttrs (
      map (name stableName) stable
      ++ map (name nightlyName) nightly
    )
    // {
      default = lib.last stable;
      master = lib.last nightly;
    };

  packages = pkgs:
    builtins.mapAttrs (name: zigRelease: pkgs.callPackage ./package {inherit zigRelease;}) releases;
in
  builtins.mapAttrs (system: packages) nixpkgs.legacyPackages
