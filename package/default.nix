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
    zls =
      if zigRelease._zls or null == null
      then (builtins.throw "no ZLS version available for Zig ${zigRelease._version}")
      else
        callPackage ./zls.nix {
          zlsVersion = zigRelease._zls._version;
          zlsRelease = zigRelease._zls.${system};
        };
  })
