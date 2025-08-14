{
  description = "A drop-in replacement for mitchellh/zig-overlay";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = {nixpkgs, ...}: {
    packages = import ../flake-packages.nix {
      inherit nixpkgs;
      name = kind: release:
        if kind == "nightly"
        then "master-${release._date}"
        else release._version;
      defaultNightlyName = "master";
    };
  };
}
