FROM alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG CURL_VERSION='7.83.1'

ENV TARGETPLATFORM=$TARGETPLATFORM
ENV BUILDPLATFORM=$BUILDPLATFORM
ENV ARCH=$TARGETPLATFORM

ENV CURL_VERSION=$CURL_VERSION

WORKDIR /code
COPY . /code
RUN ./build.sh



FROM scratch

USER 1000
COPY --chmod=555 --chown=1000 --from=builder /curl /curl

ENTRYPOINT ["/curl"]
