{ self, ... }:

[
  (final: prev: {
    i3-config = self.packages.${final.system}.default;
  })
]
