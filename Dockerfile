FROM ruby:2.6.0

RUN apt-get update && apt-get install -y squashfs-tools build-essential

WORKDIR /usr/local/bin
RUN curl -L https://github.com/kontena/ruby-packer/releases/download/0.5.0%2Bextra6/rubyc-0.5.0+extra6-linux-amd64.gz | gunzip > rubyc
#RUN curl -L https://github.com/kontena/ruby-packer/releases/download/2.6.0-0.6.0.rc1/rubyc-2.6.0-0.6.0.rc1-linux-amd64.gz | gunzip > rubyc
RUN chmod +x rubyc

RUN apt-get update && apt-get install -y bison
WORKDIR /build
COPY . .
ENTRYPOINT [ "/bin/bash" ]
#RUN bin/build binary

# FROM ubuntu:18.04

# COPY --from=builder /build/puttyd /usr/local/bin
# ENV PYTTY_BIND=0.0.0.0
# ENV PYTTY_PORT=1234
# ENTRYPOINT [ "/usr/local/bin/puttyd", "serve"]