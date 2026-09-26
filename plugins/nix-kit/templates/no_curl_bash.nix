# Boundary: no curl|bash in builders; prefer local install script.
{ pkgs }:
pkgs.writeShellScript "bootstrap" ''
  ./scripts/install.sh
''
