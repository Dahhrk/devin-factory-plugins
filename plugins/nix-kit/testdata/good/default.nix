# Good fixture: hashed fetchurl, no exec/IFD/getEnv, no world-writable, no curl|bash.
{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  pname = "hello";
  version = "1.0.0";
  src = fetchurl { url = "https://example.com/hello.tar.gz"; hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; };
  buildPhase = "cc -o hello hello.c";
  installPhase = ''
    mkdir -p $out/bin
    install -m 755 hello $out/bin/hello
  '';
}
