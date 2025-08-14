{
  pkgs,
  lib ? pkgs.lib,
}: let
  package = zigRelease: pkgs.callPackage ../package {inherit zigRelease;};
  latest = set: package (lib.last set);
  stable = import ./stable.nix;
  nightly = import ./nightly.nix;
in
  builtins.listToAttrs (
    map (v: lib.nameValuePair "zig-${v._version}" v) stable
    ++ map (v: lib.nameValuePair "zig-nightly-${v._date}" v) nightly
  )
  // rec {
    zig = zig-latest;
    zig-latest = latest stable;
    zig-nightly = latest nightly;
  }
