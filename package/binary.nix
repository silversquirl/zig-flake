# Extract and package a ZSF binary release
{
  lib,
  stdenvNoCC,
  zigSource,
  zigVersion,
}:
stdenvNoCC.mkDerivation {
  pname = "zig";
  version = zigVersion;
  meta = import ./meta.nix {
    inherit lib;
    version = zigVersion;
    date = zigSource._date or null;
  };

  src = zigSource;
  installPhase = ''
    install -Dt "$out/bin" zig
    cp -r lib doc "$out"
  '';
}
