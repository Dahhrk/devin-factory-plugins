# Boundary: no builtins.exec / IFD; prefer pure vendored path.
{ pkgs }:
pkgs.callPackage ./package.nix { }
