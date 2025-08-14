{
  description = "A Nix flake for the Zig programming language";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {nixpkgs, ...}: {
    packages = let
      lib = nixpkgs.lib;
      snakeify = version:
        lib.pipe version [
          lib.versions.splitVersion # parse version
          (lib.sublist 0 5) # strip commit hash
          (lib.concatStringsSep "_") # recombine
        ];
    in
      import ./flake-packages.nix {
        inherit nixpkgs;
        name = kind: release: "zig_${snakeify release._version}";
        defaultNightlyName = "nightly";
      };
  };
}
