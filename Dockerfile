FROM ruby:2.5.1 AS builder

RUN apt-get update && apt-get install -y squashfs-tools build-essential bison

WORKDIR /build
COPY build/linux-debian-deps.sh build/
RUN build/linux-debian-deps.sh

COPY . .
RUN build/linux.sh 0.4.1

FROM ubuntu:18.04

COPY --from=builder /build/tmp/pyttyd-linux-amd64-${version} /usr/local/bin/pyttyd

ENV PYTTY_BIND=0.0.0.0
ENV PYTTY_PORT=1234
ENTRYPOINT [ "/usr/local/bin/pyttyd" ]
