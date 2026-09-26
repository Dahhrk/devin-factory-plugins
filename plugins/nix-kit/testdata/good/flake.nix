{
  description = "good nix fixture flake";
  outputs = { self }: {
    packages.x86_64-linux.default = import ./default.nix { };
  };
}
