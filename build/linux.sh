#!/usr/bin/env sh
set -e

version=${1#"v"}
package="tmp/pyttyd-linux-amd64-${version}"
rubyc -o "$package" -d /tmp/pytty-build --make-args="-j16 --silent" pyttyd
./"$package" --version