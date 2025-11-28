{
  lib,
  stdenvNoCC,
  callPackage,
  zigRelease,
  zigMirrorUrl ? "https://ziglang.org/download/community-mirrors.txt",
  zigMirrorFile ? ../releases/community-mirrors.txt,
  zigVersion ? zigRelease._version,
}: let
  system = stdenvNoCC.hostPlatform.system;
in
  lib.throwIfNot (zigRelease ? ${system}) "Zig ${zigVersion} has no binary release for ${system}"
  (callPackage ./binary.nix {
    inherit zigVersion;
    zigSource = callPackage ./fetch.nix {
      zigRelease = zigRelease.${system};
      mirrorUrl = zigMirrorUrl;
      mirrorFile = zigMirrorFile;
    };
  })
