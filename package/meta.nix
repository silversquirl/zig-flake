{
  lib,
  version,
  date,
}:
{
  description = "The Zig programming language";
  homepage = "https://ziglang.org/";
  license = lib.licenses.mit;
  inherit version;
}
// lib.optionalAttrs (date != null) {releaseDate = date;}
