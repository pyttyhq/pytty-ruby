#!/usr/bin/env sh
set -e

export HOMEBREW_NO_AUTO_UPDATE=1
brew install squashfs || brew upgrade squashfs || true
brew install openssl || brew upgrade openssl || true

curl -sL https://curl.haxx.se/ca/cacert.pem > /usr/local/etc/openssl/cacert.pem

curl -sL https://dl.bintray.com/kontena/ruby-packer/0.5.0-dev/rubyc-0.5.0-extra2-darwin-amd64.gz | gunzip > /usr/local/bin/rubyc
chmod +x /usr/local/bin/rubyc