#!/bin/bash

function package() {
  platform=$1
  arch=$2
  rm -f murga-$platform-$arch.zip

  echo "[Murga] ...building package for $platform - $arch..."
  electron-packager . --overwrite --platform=$platform --arch=$arch

  echo "[Murga] ...compressing..."
  zip -r murga-$platform-$arch.zip murga-$platform-$arch
}

echo "[Murga] Packaging for Linux..."
package linux ia32
package linux x64

echo "[Murga] Packaging for Windows..."
package win32 ia32
package win32 x64
