# Extract and package a ZSF binary release
{
  lib,
  stdenvNoCC,
  callPackage,
  hostPlatform,
  coreutils,
  xcbuild,
  zigSource,
  zigVersion,
}: let
  zig = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "zig";
    version = zigVersion;
    meta = import ./meta.nix {
      inherit lib;
      version = finalAttrs.version;
      date = zigSource._date or null;
    };
    passthru = {
      fetchDeps = callPackage ./fetch-deps.nix {inherit zig;};

      makePackage = {
        stdenv ? stdenvNoCC,
        src,
        depsHash ? lib.fakeHash,
        nativeBuildInputs ? [],
        ...
      } @ args:
        stdenv.mkDerivation (final:
          {
            inherit src;
            zigDeps = args.zigDeps or finalAttrs.passthru.fetchDeps {
              inherit (final) src;
              name = final.name or null;
              pname = final.pname or null;
              version = final.version or null;
              hash = depsHash;
            };
            nativeBuildInputs = nativeBuildInputs ++ [zig];
          }
          // lib.removeAttrs args ["stdenv" "nativeBuildInputs" "depsHash"]);
    };

    src = zigSource;

    # xcbuild provides xcode-select, which is required for SDK detection on macos
    buildInputs = lib.optional hostPlatform.isDarwin xcbuild;
    propagatedBuildInputs = lib.optional hostPlatform.isDarwin xcbuild;

    # zig-flake's setup hook only supports Zig 0.12 or later due to using `--release`
    # TODO: print an error in the setup hook, rather than silently disabling it
    setupHook =
      if (lib.versionAtLeast zig.version "0.12")
      then ./setup-hook.sh
      else null;

    postPatch =
      # Zig's build looks at /usr/bin/env to find dynamic linking info. This doesn't
      # work in Nix's sandbox. Use env from our coreutils instead.
      ''
        substituteInPlace lib/std/zig/system.zig \
          --replace "/usr/bin/env" "${lib.getExe' coreutils "env"}"
      ''
      # Zig tries to access xcrun and xcode-select at the absolute system path to query the macOS SDK
      # location, which does not work in the darwin sandbox.
      # Upstream issue: https://github.com/ziglang/zig/issues/22600
      # Note that while this fix is already merged upstream and will be included in 0.14+,
      # we can't fetchpatch the upstream commit as it won't cleanly apply on older versions,
      # so we substitute the paths instead.
      + lib.optionalString (hostPlatform.isDarwin && lib.versionOlder finalAttrs.version "0.14") ''
        substituteInPlace lib/std/zig/system/darwin.zig \
          --replace /usr/bin/xcrun xcrun \
          --replace /usr/bin/xcode-select xcode-select
      '';

    installPhase = ''
      install -Dt "$out/bin" zig
      cp -r lib doc "$out"
    '';
  });
in
  zig
