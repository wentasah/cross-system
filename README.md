```
 $ nix-build -A armv6l-linux.sdImage
 $ nix-build -A armv7l-linux.sdImage
 $ nix-build -A armv7l-linux.isoImage
 $ nix-build -A aarch64-linux.sdImage
 $ nix-build -A aarch64-linux.isoImage
 $ nix-build -A aarch64-linux.rootfs --builders 'build-server x86_64-linux "" 8 1 big-parallel''
```
