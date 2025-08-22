{
  lib,
  runCommand,
  zig,
}: {
  pname ? null,
  version ? null,
  name ? null,
  src,
  hash ? lib.fakeHash,
}: let
  fullName =
    if name != null
    then name
    else
      lib.throwIf (pname == null || version == null) "fetchDeps: must provide either `pname` and `version` or `name`"
      "${pname}-${version}";
in
  runCommand "${fullName}-zig-deps" {
    src = src + "/build.zig.zon";
    nativeBuildInputs = [zig];
    outputHash = hash;
    outputHashMode = "recursive";
  } ''
    export ZIG_GLOBAL_CACHE_DIR="$PWD/zig-cache"
    export ZIG_LOCAL_CACHE_DIR="$ZIG_GLOBAL_CACHE_DIR"
    touch build.zig # just needs to exist, not actually be valid
    cp "$src" build.zig.zon
    TERM=dumb zig build --fetch
    mkdir -p "$ZIG_GLOBAL_CACHE_DIR/p" # in case there were no deps to fetch
    cp -r "$ZIG_GLOBAL_CACHE_DIR/p" "$out"
  ''
