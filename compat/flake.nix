{
  description = "A drop-in replacement for mitchellh/zig-overlay";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {nixpkgs, ...}: {
    packages = import ./flake-packages.nix {
      inherit nixpkgs;
      stableName = r: r._version;
      nightlyName = r: "master-${r._date}";
      defaultNightlyName = "master";
    };
  };
}
