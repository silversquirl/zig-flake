# zig-flake

This Nix flake provides access to binary builds of Zig, including the latest nightlies.
It also includes a setup hook, dependency fetcher, and packaging helper function, to make creating
Nix packages for your Zig projects as seamless as possible.

## Usage

Here's a simple example of a packaging a Zig project using a flake.nix:

```nix
{
  inputs.zig.url = "github:silversquirl/zig-flake";
  outputs = {zig, ...}: {
    packages =
      builtins.mapAttrs (system: zigPkgs: {
        default = zigPkgs.default.makePackage {
          pname = "<package name>";
          version = "0.1.0";
          src = ./.;
          zigReleaseMode = "fast"; # or "safe" or "small"; only needed if you don't set a preferred release mode in your build.zig
          #depsHash = "<fill this in from the error message>";
        };
      })
      zig.packages;
  };
}
```

You can also create a devshell with a matching version of zls, using zig-flake's [compatibility layer](#compatibility-with-zig-overlay):

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs";
    zig.url = "github:silversquirl/zig-flake/compat";
    zls.url = "github:zigtools/zls";

    zig.inputs.nixpkgs.follows = "nixpkgs";
    zls.inputs.nixpkgs.follows = "nixpkgs";
    zls.inputs.zig-overlay.follows = "zig";
  };

  outputs = {
    nixpkgs,
    zig,
    zls,
    ...
  }: let
    forAllSystems = f: builtins.mapAttrs f nixpkgs.legacyPackages;
  in {
    devShells = forAllSystems (system: pkgs: {
      default = pkgs.mkShellNoCC {
        packages = [
          pkgs.bash
          zig.packages.${system}.nightly
          zls.packages.${system}.zls
        ];
      };
    });
  };
}
```

## Comparison with other alternatives

There are a few other projects similar to this one, including @mitchellh's [zig-overlay] and @Cloudef's [zig2nix].
Zig is also packaged in nixpkgs, so for some projects you may not even need a flake at all.

Here is a feature comparison between these options:

| Feature                                       | zig-flake                        | nixpkgs                                   | [zig-overlay]                  | [zig2nix]                                 |
| --------------------------------------------- | -------------------------------- | ----------------------------------------- | ------------------------------ | ----------------------------------------- |
| Binary packages                               | :white_check_mark:               | :x:                                       | :white_check_mark:             | :white_check_mark:                        |
| Source packages                               | :x:                              | :white_check_mark:                        | :x:                            | :white_check_mark:                        |
| Setup hook                                    | :white_check_mark:               | :white_check_mark:                        | :x:                            | :white_check_mark:                        |
| Dependency fetcher                            | :white_check_mark:               | :ballot_box_with_check:[^nixpkgs-fetcher] | :x:                            | :ballot_box_with_check:[^zig2nix-fetcher] |
| Packaging helper function[^helper]            | :white_check_mark:               | :x:                                       | :x:                            | :white_check_mark:                        |
| Flake templates                               | :white_check_mark:               | :x:                                       | :x:                            | :warning:[^zig2nix-template]              |
| Languages used by the flake                   | Nix, Bash                        | Nix, Bash                                 | Nix                            | Nix, Bash, Zig                            |
| Dependencies (excluding nixpkgs)              | none                             | N/A                                       | flake-utils[^fu], flake-compat | flake-utils[^fu]                          |
| Flake closure size (excluding nixpkgs)[^size] | 54KiB                            | N/A                                       | 1.8MiB                         | 306KiB                                    |
| Compatible with nixpkgs package names         | :white_check_mark:               | :white_check_mark:                        | :x:                            | :x:                                       |
| Compatible with zig-overlay package names     | :ballot_box_with_check:[^compat] | :x:                                       | :white_check_mark:             | :x:                                       |

[^nixpkgs-fetcher]: the dependency fetcher provided by nixpkgs requires extra care to avoid refetching dependencies every time you change a source file
[^zig2nix-fetcher]: zig2nix requires generating a Nix file based on your build.zig.zon. zig-flake and nixpkgs simply require keeping a single hash up to date
[^helper]: automatically fetches dependencies and installs the setup hook, just to save a bit of boilerplate
[^zig2nix-template]: the flake templates provided by zig2nix already have a skeleton Zig project in them, as generated by `zig init`.
  While this sounds like a great idea on the surface, it actually causes two problems:

  1. Experienced Zig users typically do not use the default `zig init` template, as it's more of a tutorial than anything.
  2. `zig init` randomly generates a package fingerprint based on the package name.
     Hardcoding this into a Nix flake template is a serious issue, as it means all projects generated by that template will use the same fingerprint.

  In comparison, zig-flake's templates only contain a `flake.nix` and a minimal `.gitignore`, allowing users to choose whether to use
  `zig init`, `zig init -m`, or write their whole project structure by hand

[^fu]: flake-utils provides helper functions for creating Nix flakes.
  However, these functions are overcomplicated, and the same result can be trivially achieved using `builtins.mapAttrs`, as shown in the examples above, so it doesn't really serve any purpose.
  Because of this, most Nix veterans I've spoken to recommend against the use of flake-utils.
[^size]: calculated using `nix path-info --closure-size $(nix flake archive --json | jq -r 'recurse(.inputs? // empty | del(.nixpkgs)[]) | .path') | awk '{total += $2}; END {print total}' | numfmt --to=iec-i --suffix=B`
[^compat]: only when using the [compatibility layer](#compatibility-with-zig-overlay)

### Compatibility with zig-overlay

The most widely used flake for Zig is @mitchellh's [zig-overlay]. This flake uses a different package naming scheme than zig-flake (whose naming scheme is based on nixpkgs).
In order to allow flakes that depend on zig-overlay to easily switch to zig-flake, and to allow using `follows` to override dependencies' uses of zig-overlay,
zig-flake provides a compatibility layer that exposes all its packages with additional names, matching the zig-overlay naming scheme.

To use it, simply use the `compat` branch:

```nix
{
  inputs = {
    zig.url = "github:silversquirl/zig-overlay/compat";
    other-flake.url = "...";
    other-flake.inputs.zig-overlay.follows = "zig";
  };

  # ...
}
```

[zig-overlay]: https://github.com/mitchellh/zig-overlay
[zig2nix]: https://github.com/Cloudef/zig2nix/
