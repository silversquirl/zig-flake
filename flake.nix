{
  description = "A Nix flake for the Zig programming language";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {nixpkgs, ...}: {
    packages = let
      snakeify = builtins.replaceStrings ["." "-"] ["_" "_"];
    in
      import ./flake-packages.nix {
        inherit nixpkgs;
        stableName = r: "zig_${snakeify r._version}";
        nightlyName = r: "zig_nightly_${snakeify r._date}";
      };
  };
}
