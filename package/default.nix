{
  lib,
  stdenvNoCC,
  callPackage,
  zigRelease,
  zigMirrors ? null,
  zigVersion ? zigRelease._version,
}: let
  system = stdenvNoCC.hostPlatform.system;
in
  lib.throwIfNot (zigRelease ? ${system}) "Zig ${zigVersion} has no binary release for ${system}"
  (callPackage ./binary.nix {
    inherit zigVersion;
    zigSource = callPackage ./fetch.nix (
      {zigRelease = zigRelease.${system};}
      // lib.optionalAttrs (zigMirrors != null) {inherit zigMirrors;}
    );
  })
