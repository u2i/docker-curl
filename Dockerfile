FROM alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG CURL_VERSION='7.83.1'

ENV TARGETPLATFORM=$TARGETPLATFORM
ENV BUILDPLATFORM=$BUILDPLATFORM
ENV ARCH=$TARGETPLATFORM

ENV CURL_VERSION=$CURL_VERSION
ENV CC=clang

WORKDIR /code
COPY mykey.asc /code


ENV CURL_NAME="curl-${CURL_VERSION}"
ENV FILE_NAME="${CURL_NAME}.tar.gz"

RUN apk add --no-cache \
      --virtual deps \
      build-base clang openssl-dev nghttp2-dev nghttp2-static libssh2-dev libssh2-static && \
    apk add --no-cache \
      --virtual deps-ssl \
      openssl-libs-static zlib-static || true

RUN apk add --no-cache --virtual fetch gnupg curl && \
    curl -L "https://curl.haxx.se/download/${FILE_NAME}" -o "${FILE_NAME}" && \
    curl -L "https://curl.haxx.se/download/${FILE_NAME}.asc" -o "${FILE_NAME}.asc" && \
    gpg --no-default-keyring --yes -o ./curl.gpg --dearmor mykey.asc && \
    gpg --no-default-keyring --keyring ./curl.gpg --verify "${FILE_NAME}.asc" && \
    tar xzf "${FILE_NAME}" --strip-components 1 && \
    rm "${FILE_NAME}" "${FILE_NAME}.asc" curl.gpg && \
    apk del fetch

RUN LDFLAGS="-static" PKG_CONFIG="pkg-config --static" \
      ./configure --disable-shared --enable-static --disable-libcurl-option --without-brotli --disable-manual --disable-unix-sockets --disable-dict --disable-file --disable-gopher --disable-imap --disable-smtp --disable-rtsp --disable-telnet --disable-tftp --disable-pop3 --without-zlib --disable-threaded-resolver --disable-ipv6 --disable-smb --disable-ntlm-wb --disable-tls-srp --disable-crypto-auth --without-ngtcp2 --without-nghttp2 --disable-ftp --disable-mqtt --disable-alt-svc --without-ssl

COPY build.sh /code
RUN ./build.sh



FROM scratch

USER 1000
COPY --chmod=555 --chown=1000 --from=builder /curl /curl

ENTRYPOINT ["/curl"]
