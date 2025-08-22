{
  inputs = {
    zig.url = "github:silversquirl/zig-flake";
  };

  outputs = {zig, ...}: {
    packages =
      builtins.mapAttrs (system: zigPkgs: {
        default = zigPkgs.default.makePackage {
          pname = "zig-flake-template";
          version = "0.0.0";
          src = ./.;
          zigReleaseMode = "fast";
          # depsHash = "<replace this with the hash Nix provides in its error message>"
        };
      })
      zig.packages;
  };
}
