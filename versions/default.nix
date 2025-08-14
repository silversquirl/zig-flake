{
  pkgs,
  lib ? pkgs.lib,
}: let
  package = zigRelease: pkgs.callPackage ../package {inherit zigRelease;};
  latest = set: package (lib.last set);
  stable = import ./stable.nix;
  nightly = import ./nightly.nix;

  snakeify = builtins.replaceStrings ["." "-"] ["_" "_"];
in
  builtins.listToAttrs (
    map (v: lib.nameValuePair "zig_${snakeify v._version}" (package v)) stable
    ++ map (v: lib.nameValuePair "zig_nightly_${snakeify v._date}" (package v)) nightly
  )
  // rec {
    zig = zig_latest;
    zig_latest = latest stable;
    zig_nightly = latest nightly;
  }
