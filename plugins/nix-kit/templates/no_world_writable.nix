# Boundary: no chmod 777 / a+w / umask 000 in builders.
{ pkgs }:
pkgs.writeShellScript "install" ''
  mkdir -p "$out/bin"
  install -m 755 ./tool "$out/bin/tool"
''
