{
  lib,
  version,
  date,
}:
{
  description = "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software";
  homepage = "https://ziglang.org/";
  changelog = "https://ziglang.org/download/${version}/release-notes.html";
  license = lib.licenses.mit;
  mainProgram = "zig";
  platforms = lib.platforms.unix;
}
// lib.optionalAttrs (date != null) {releaseDate = date;}
