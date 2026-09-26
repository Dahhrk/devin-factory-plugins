# Boundary: fetchurl / fetchTarball with hash on the same call line.
{ fetchurl }:
fetchurl { url = "https://example.com/hello.tar.gz"; hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; }
