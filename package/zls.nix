# Extract and package a ZLS binary release
{
  stdenvNoCC,
  fetchurl,
  zlsVersion,
  zlsRelease,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zls";
  version = zlsVersion;
  meta.mainProgram = "zls";
  src = fetchurl {
    url = zlsRelease.tarball;
    outputHash = zlsRelease.shasum;
    outputHashAlgo = "sha256";
  };
  sourceRoot = ".";
  installPhase = ''
    install -Dt "$out/bin" zls
  '';
})
