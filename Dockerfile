FROM ruby:2.5.1 AS builder

RUN apt-get update && apt-get install -y squashfs-tools build-essential bison

WORKDIR /build
COPY build/linux-debian-deps.sh build/
RUN build/linux-debian-deps.sh

COPY . .
RUN build/linux.sh latest

# -----------------------
FROM ubuntu:18.04

COPY --from=builder /build/pyttyd-linux-amd64-latest /usr/local/bin/pyttyd

ENV PYTTYD_BIND=0.0.0.0
ENV PYTTYD_PORT=1234
ENTRYPOINT [ "/usr/local/bin/pyttyd" ]
