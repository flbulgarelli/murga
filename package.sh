#!/bin/bash

echo "[Murga] Packaging for Linux..."
electron-packager . --overwrite --platform=linux --arch=ia32
electron-packager . --overwrite --platform=linux --arch=x64

echo "[Murga] Packaging for Windows..."
electron-packager . --overwrite --platform=win32 --arch=ia32
electron-packager . --overwrite --platform=win32 --arch=x64