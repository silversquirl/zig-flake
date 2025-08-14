{
  lib,
  hostPlatform,
  callPackage,
  zigRelease,
  zigMirrors ? ../releases/community-mirrors.txt,
  zigVersion ? zigRelease._version,
}: let
  system = hostPlatform.system;
in
  lib.throwIfNot (zigRelease ? ${system}) "Zig ${zigVersion} has no binary release for ${system}"
  (callPackage ./binary.nix {
    inherit zigVersion;
    zigSource = callPackage ./fetch.nix {
      inherit zigMirrors;
      zigRelease = zigRelease.${system};
    };
  })
