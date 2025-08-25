{
  description = "A Nix flake for the Zig programming language";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {
    self,
    nixpkgs,
  }: {
    releases = let
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
    in
      builtins.listToAttrs (
        map named stable
        ++ map named nightly
      )
      // {
        default = lib.last stable;
        nightly = lib.last nightly;
      };

    fetchRelease = pkgs:
      pkgs.callPackage ./package/fetch.nix {
        zigRelease = self.releases.${pkgs.hostPlatform.system};
      };

    packages =
      builtins.mapAttrs
      (system: pkgs: let
        forThisSystem =
          nixpkgs.lib.filterAttrs (name: rel: rel ? ${pkgs.hostPlatform.system}) self.releases;
        package = name: rel: pkgs.callPackage ./package {zigRelease = rel;};
      in
        builtins.mapAttrs package forThisSystem)
      nixpkgs.legacyPackages;

    templates = {
      default = {
        path = ./templates/default;
        description = "Simple Nix flake for a package using the latest stable Zig release";
      };
      nightly = {
        path = ./templates/nightly;
        description = "Nix flake with devShell, for a package using the latest Zig nightly";
      };
    };
  };
}
