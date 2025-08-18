{
  description = "A Nix flake for the Zig programming language";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {nixpkgs, ...}: {
    packages = let
      inherit (nixpkgs) lib;

      stable = import ./releases/stable.nix;
      nightly = import ./releases/nightly.nix;

      named = release: {
        name =
          "zig_"
          + lib.pipe release._version [
            lib.versions.splitVersion # parse version
            (lib.sublist 0 5) # strip commit hash
            (lib.concatStringsSep "_") # recombine
          ];
        value = release;
      };

      releases =
        builtins.listToAttrs (
          map named stable
          ++ map named nightly
        )
        // {
          default = lib.last stable;
          nightly = lib.last nightly;
        };

      packages = pkgs: let
        filtered = lib.filterAttrs (name: rel: rel ? ${pkgs.hostPlatform.system}) releases;
        package = name: rel: pkgs.callPackage ./package {zigRelease = rel;};
      in
        builtins.mapAttrs package filtered;
    in
      builtins.mapAttrs (system: packages) nixpkgs.legacyPackages;
  };
}
