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

  packages = pkgs: let
    filtered = lib.filterAttrs (name: rel: rel ? ${pkgs.hostPlatform.system}) releases;
    package = name: rel: pkgs.callPackage ./package {zigRelease = rel;};
  in
    builtins.mapAttrs package filtered;
in
  builtins.mapAttrs (system: packages) nixpkgs.legacyPackages
