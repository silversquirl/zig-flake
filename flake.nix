{
  description = "A Nix flake for the Zig programming language";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
  }: {
    releases = let
      inherit (nixpkgs) lib;

      stable = import ./releases/stable.nix;
      nightly = import ./releases/nightly.nix;

      named = release: let
        matchesVersion = zls:
          builtins.compareVersions
          (lib.versions.majorMinor release._version)
          (lib.versions.majorMinor zls._version)
          == 0;
        zlsFallbacks = builtins.filter matchesVersion (import ./releases/zls.nix);
        zlsFallback =
          if zlsFallbacks == []
          then null
          else lib.last zlsFallbacks;
      in {
        name =
          "zig_"
          + lib.pipe release._version [
            builtins.splitVersion # parse version
            (lib.sublist 0 5) # strip commit hash
            (lib.concatStringsSep "_") # recombine
          ];
        value = {_zls = zlsFallback;} // release;
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

    fetchRelease = ./package/fetch.nix;

    packages =
      builtins.mapAttrs
      (system: pkgs: let
        forThisSystem =
          nixpkgs.lib.filterAttrs (name: rel: rel ? ${pkgs.stdenv.hostPlatform.system}) self.releases;
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
