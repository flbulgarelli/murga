#!/bin/bash
set -e

echo "[Ikumi::Offline] Generating site..."
pushd offline-primaria
./fetch.sh
popd
pushd offline
./fetch.sh
popd

echo "[Ikumi::Offline] Copying contents..."
cp ./offline-primaria/contents/*.html primaria/
cp ./offline/contents/*.html secundaria/

echo "[Ikumi::Offline] Copying assets..."
cp ./offline/assets/* assets/
cp ./offline-primaria/assets/* assets/
