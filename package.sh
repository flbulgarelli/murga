#!/bin/bash

function package() {
  platform=$1
  arch=$2
  rm -f mumuki-$platform-$arch.zip

  echo "[Murga] ...building package for $platform - $arch..."
  electron-packager . mumuki --overwrite --platform=$platform --arch=$arch --ignore="server|.git(ignore|modules)?|mumuki-.*|build.sh|package.sh"

  echo "[Murga] ...compressing..."
  zip -r mumuki-$platform-$arch.zip mumuki-$platform-$arch
}

echo "[Murga] Packaging for Linux..."
package linux ia32
package linux x64

echo "[Murga] Packaging for Windows..."
package win32 ia32
package win32 x64
