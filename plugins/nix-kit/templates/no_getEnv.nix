# Boundary: no builtins.getEnv; pass config explicitly.
{ config ? {} }:
config.feature or false
