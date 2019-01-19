#!/usr/bin/env sh
set -e

sudo apt-get update && sudo apt-get install -y squashfs-tools build-essential bison curl

curl -L https://github.com/kontena/ruby-packer/releases/download/0.5.0%2Bextra7/rubyc-0.5.0+extra7-linux-amd64.gz | gunzip > /usr/local/bin/rubyc
chmod +x /usr/local/bin/rubyc
