{
  stdenvNoCC,
  curl,
  minisign,
  zigMirrors,
  zigRelease,
}:
stdenvNoCC.mkDerivation {
  name = zigRelease.filename;
  builder = ./fetch_builder.sh;
  nativeBuildInputs = [curl minisign];

  mirrorFile = zigMirrors;
  inherit (zigRelease) filename;
  urlQuery = "?source=silversquirl/zig-flake";
  minisignPublicKey = "RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U";

  outputHash = zigRelease.shasum;
  outputHashAlgo = "sha256";
  outputHashMode = "flat";

  postHook = null;
  preferLocalBuild = true;
}
