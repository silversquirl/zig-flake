{
  inputs = {
    nixpkgs.url = "nixpkgs";
    zig.url = "github:silversquirl/zig-flake";
    zig.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    zig,
    ...
  }: let
    forAllSystems = f:
      builtins.mapAttrs
      (system: pkgs: f pkgs zig.packages.${system}.nightly)
      nixpkgs.legacyPackages;
  in {
    devShells = forAllSystems (pkgs: zig: {
      default = pkgs.mkShellNoCC {
        packages = [pkgs.bash zig zig.zls];
      };
    });

    packages = forAllSystems (pkgs: zig: {
      default = zig.makePackage {
        pname = "zig-flake-template";
        version = "0.0.0";
        src = ./.;
        zigReleaseMode = "fast";
        # depsHash = "<replace this with the hash Nix provides in its error message>"
      };
    });
  };
}
