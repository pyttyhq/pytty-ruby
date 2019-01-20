#!/usr/bin/env sh
set -ue

version=${TRAVIS_TAG#"v"}
package="pyttyd-darwin-amd64-${version}"

rubyc --openssl-dir=/usr/local/etc/openssl -o "$package" -d /tmp/pytty-build-macos --make-args="-j16 --silent" pyttyd
./"$package" --version
