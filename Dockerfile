FROM --platform=amd64 alpine

ENV ARCH=amd64

WORKDIR /code

COPY . /code

RUN ./build.sh
