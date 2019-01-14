#!/usr/bin/env sh
set -e

version=${TRAVIS_TAG#"v"}
package="tmp/pyttyd-linux-amd64-${version}"
rubyc -o "$package" -d /tmp/pytty-build --make-args="-j16 --silent" pyttyd
./"$package" --version