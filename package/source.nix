# Build Zig from source
{
  lib,
  pkgs,
  stdenv,
  cmake,
  ninja,
  libxml2,
  zlib,
  zstd,
  zigSource,
  zigVersion,
}:
lib.throwIf (lib.versionOlder zigVersion "0.9")
''
  This package does not support building Zig versions older than 0.9.0 from source.
  However, you may use the binary package for versions all the way down to 0.5.0 or lower.
''
(let
  # LLVM 13 is the first version that Zig explicitly tagged, during the 0.9 release cycle
  minLlvm = 13;
  maxLlvm = lib.strings.toInt (lib.versions.major pkgs.llvmPackages_latest.llvm.version);
  llvmVersions = builtins.map (v: pkgs.${"llvmPackages_" + builtins.toString v}) (lib.range minLlvm maxLlvm);
in
  stdenv.mkDerivation {
    pname = "zig";
    version = zigVersion;
    src = zigSource;

    nativeBuildInputs = [
      cmake
      ninja
    ];

    buildInputs =
      [
        libxml2
        zlib
        zstd
      ]
      ++ builtins.concatMap (llvm: [
        llvm.clang
        llvm.clang-unwrapped.lib
        llvm.lld
        llvm.llvm
      ])
      llvmVersions;
  })
