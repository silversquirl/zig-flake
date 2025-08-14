{
  lib,
  hostPlatform,
  callPackage,
  zigRelease,
  zigMirrors ? ../releases/community-mirrors.txt,
  zigVersion ? zigRelease._version,
}: let
  fromSource = callPackage ./source.nix {
    inherit zigVersion;
    zigSource = callPackage ./fetch.nix {
      inherit zigMirrors;
      zigRelease = zigRelease.src;
    };
  };

  system = hostPlatform.system;
  hasBinaryRelease = zigRelease ? ${system};
  binary =
    lib.throwIfNot hasBinaryRelease "Zig ${zigVersion} has no binary release for ${system}"
    (callPackage ./binary.nix {
      inherit zigVersion;
      zigSource = callPackage ./fetch.nix {
        inherit zigMirrors;
        zigRelease = zigRelease.${system};
      };
    });

  default =
    if hasBinaryRelease
    then binary
    else fromSource;
in
  default // {inherit binary fromSource;}
