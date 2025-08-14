{
  nixpkgs,
  name,
  defaultNightlyName,
}: let
  inherit (nixpkgs) lib;

  stable = import ./releases/stable.nix;
  nightly = import ./releases/nightly.nix;

  named = kind: release: {
    name = name kind release;
    value = release;
  };

  releases =
    builtins.listToAttrs (
      map (named "stable") stable
      ++ map (named "nightly") nightly
    )
    // {
      default = lib.last stable;
      ${defaultNightlyName} = lib.last nightly;
    };

  packages = pkgs: let
    filtered = lib.filterAttrs (name: rel: rel ? ${pkgs.hostPlatform.system}) releases;
    package = name: rel: pkgs.callPackage ./package {zigRelease = rel;};
  in
    builtins.mapAttrs package filtered;
in
  builtins.mapAttrs (system: packages) nixpkgs.legacyPackages
