#!/usr/bin/env sh
set -e

version=${1#"v"}
package="tmp/pyttyd-linux-amd64-${version}"
rubyc -o "$package" -d /tmp/pytty-build --make-args="-j$((`nproc`+1)) --silent" pyttyd
./"$package" --version
