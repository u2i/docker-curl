#!/bin/sh

# docker buildx build --platform linux/amd64,linux/arm64 -t curl:slim .
# LDFLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure --disable-shared --enable-static --disable-ldap --enable-ipv6 --enable-unix-sockets --with-ssl --with-libssh2

make -j V=1 LDFLAGS="-static -all-static"

# binary is ~13M before stripping, 2.6M after
strip src/curl

# print out some info about this, size, and to ensure it's actually fully static
ls -lah src/curl
file src/curl
# exit with error code 1 if the executable is dynamic, not static
ldd src/curl && exit 1 || true

./src/curl -V

mv src/curl "/curl"

# curl static binary will be available at /curl without execute permissions
