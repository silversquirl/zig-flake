{
  description = "A Nix flake for the Zig programming language, that also works as a drop-in replacement for mitchellh/zig-overlay";
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

      compatNamed = {
        stable = release: {
          name = release._version;
          value = release;
        };
        nightly = release: {
          name = "master-${release._date}";
          value = release;
        };
      };
    in
      builtins.listToAttrs (
        map named stable
        ++ map named nightly
        ++ map compatNamed.stable stable
        ++ map compatNamed.nightly nightly
      )
      // {
        default = lib.last stable;
        nightly = lib.last nightly;
        master = lib.last nightly;
      };

    fetchRelease = ./package/fetch.nix;

    packages =
      builtins.mapAttrs
      (system: pkgs: let
        forThisSystem =
          nixpkgs.lib.filterAttrs (name: rel: rel ? ${pkgs.hostPlatform.system}) self.releases;
        package = name: rel: pkgs.callPackage ./package {zigRelease = rel;};
      in
        # TODO: expose zls packages at top level
        builtins.mapAttrs package forThisSystem)
      nixpkgs.legacyPackages;

    devShells =
      builtins.mapAttrs
      (system:
        builtins.mapAttrs (name: zig: let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          pkgs.mkShellNoCC {
            packages = [pkgs.bash zig] ++ pkgs.lib.optional (zig ? zls) zig.zls;
          }))
      self.packages;

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
