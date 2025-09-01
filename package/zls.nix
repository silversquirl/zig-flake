# Build the matching ZLS version for the given Zig package
{
  lib,
  fetchFromGitHub,
  zig,
}: let
  # TODO: nightlies
  # TODO: more versions
  versions = {
    "0.14" = {
      src = fetchFromGitHub {
        owner = "zigtools";
        repo = "zls";
        rev = "0.14.0";
        hash = "sha256-A5Mn+mfIefOsX+eNBRHrDVkqFDVrD3iXDNsUL4TPhKo=";
      };
      depsHash = "sha256-5ub+AA2PYuHrzPfouii/zfuFmQfn6mlMw4yOUDCw3zI=";
    };
    "0.15" = {
      src = fetchFromGitHub {
        owner = "zigtools";
        repo = "zls";
        rev = "0.15.0";
        hash = "sha256-GFzSHUljcxy7sM1PaabbkQUdUnLwpherekPWJFxXtnk=";
      };
      depsHash = "sha256-lyqTRZxsipitdP1gFupdzMH+0crP7LXRRCYUWkjhKEg=";
    };
  };
  attrs = versions.${lib.versions.majorMinor zig.version};
in
  zig.makePackage {
    pname = "zls";
    version = attrs.src.rev;
    meta.mainProgram = "zls";
    zigReleaseMode = "safe";
    doCheck = true;
    inherit (attrs) src depsHash;
  }
