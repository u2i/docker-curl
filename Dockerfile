FROM alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG CURL_VERSION='7.83.1'

ENV TARGETPLATFORM=$TARGETPLATFORM
ENV BUILDPLATFORM=$BUILDPLATFORM
ENV ARCH=$TARGETPLATFORM

ENV CURL_VERSION=$CURL_VERSION

WORKDIR /code
COPY mykey.asc /code


ENV CURL_NAME="curl-${CURL_VERSION}"
ENV FILE_NAME="${CURL_NAME}.tar.gz"

    # for gpg verification of the curl download below
    # convert mykey.asc to a .pgp file to use in verification
RUN apk add --no-cache --virtual fetch gnupg curl && \
    curl -L "https://curl.haxx.se/download/${FILE_NAME}" -o "${FILE_NAME}" && \
    curl -L "https://curl.haxx.se/download/${FILE_NAME}.asc" -o "${FILE_NAME}.asc" && \
    gpg --no-default-keyring --yes -o ./curl.gpg --dearmor mykey.asc && \
    gpg --no-default-keyring --keyring ./curl.gpg --verify "${FILE_NAME}.asc" && \
    apk del fetch


RUN apk add --no-cache \
      --virtual deps \
      build-base clang openssl-dev nghttp2-dev nghttp2-static libssh2-dev libssh2-static && \
    apk add --no-cache \
      --virtual deps-ssl \
      openssl-libs-static zlib-static || true

COPY . /code

RUN ./build.sh

RUN apk del deps deps-ssl



FROM scratch

USER 1000
COPY --chmod=555 --chown=1000 --from=builder /curl /curl

ENTRYPOINT ["/curl"]
