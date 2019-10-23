#!/bin/bash
set -e

echo '   _____                              '
echo '  /     \  __ _________  _________    '
echo ' /  \ /  \|  |  \_  __ \/ ___\__  \   '
echo '/    Y    \  |  /|  | \/ /_/  > __ \_ '
echo '\____|__  /____/ |__|  \___  (____  / '
echo '        \/            /_____/     \/  '

#############
## Clenaup ##
#############

rm -rf exercises
rm -rf lessons
rm -rf chapters
rm -rf books
rm -rf assets
rm -rf character

mkdir exercises
mkdir lessons
mkdir chapters
mkdir books
mkdir assets
mkdir -p character/kibi
mkdir -p character/magnifying_glass


###############
## Functions ##
###############

function clone_and_start() {
  repo=$1
  install_script=$2
  start_script=$3
  port=$4
  echo "[Murga] Checking whether there is a local copy of $repo..."
  mkdir -p server
  pushd server
  if [[ ! -e $repo ]]; then
    echo "[Murga] ... $repo not found! Clonning..."
    git clone git@github.com:flbulgarelli/mumuki-$repo.git $repo
    pushd mumuki-$repo
    $install_script
    popd
  fi

  echo "[Murga] Checking whether $repo is running..."
  if ! lsof -i :$port; then
    echo "[Murga] ... $repo is down. Staring it up..."
    pushd $repo
    $start_script >/dev/null 2>&1 &
    popd
  fi
  popd
}

function on_exit() {
  echo '[Murga] Killing danlingjobs'
  for i in $(jobs -p); do
    kill $i
  done
}

function fetch() {
  source=$1
  destination=$2
  curl "http://localhost:3000/$source" -H 'Connection: keep-alive' \
                                        -H 'Pragma: no-cache' \
                                        -H 'Cache-Control: no-cache' \
                                        -H 'Upgrade-Insecure-Requests: 1' \
                                        -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
                                        -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
                                        -H 'Accept-Encoding: gzip, deflate, br' \
                                        -H 'Accept-Language: en-US,en;q=0.9,es;q=0.8' \
                                        -H 'Cookie: login_organization=central; mucookie_session=ZC9WMkRHRUNDenprcjhEMzJNUTJBSHI4cHpKOTcyYUw5eE1tdnIyZ0IzRUxZT09FV0RNT3lBSTZncTd5SGUyUy0tZE1uMk5zU2hKbXV1bnVJQVFaS2U3QT09--ea631ca355fff10f5e243b46b512c3d953bcf169; mucookie_profile=eyJ1c2VyX25hbWUiOiIgIiwidXNlcl9pbWFnZV91cmwiOiJ1c2VyX3NoYXBl%0ALnBuZyJ9%0A; _mumuki_laboratory_session=R05SOURjK01RcFBtdHBzN21NZzZGNTc2K2RpS0NTRmd2Mk5TdFhLdUNhb0lMeEUvdjFCeTVYdmplSGgxSjMrQnlVd0pnYUFlUWFxSE9MeEVSUmxtZEtYa1FhT2w2Y1pPSXRkQU1XOWNEbjRvcWVBRmQ3L3E3OUxEYmdjN3EzdE5lU0E0Y2ZTdkk3dW10R1lPTGExQXVBPT0tLXRyeHd3TEk3TytDVFI5UWx3SlJZY0E9PQ%3D%3D--401b58bffa9a691f8bfabc687a5a54f91b25cba3' \
                                        --compressed -s > $destination

}


############
## Script ##
############

trap on_exit EXIT

clone_and_start laboratory ./devinit ./devstart 3000
clone_and_start "gobstones-runner" "bundle install" "bundle exec rackup" 9292

echo "[Murga] Fetching exercises..."
for i in {1..139}; do
  echo "[Murga] ...fetching exercise $i"
  fetch "central/exercises/$i" "exercises/$i.html"
done

echo "[Murga] Fetching lessons..."

for i in {1..14}; do
  echo "[Murga] ...fetching lessons $i"
  fetch "central/lessons/$i" "lessons/$i.html"
done

echo "[Murga] Fetching chapters..."

for i in {1..7}; do
  echo "[Murga] ...fetching chapters $i"
  fetch "central/chapters/$i" "chapters/$i.html"
done

echo "[Murga] ...fetching book 1"
fetch "central/books/1" "books/1.html"

echo "[Murga] Fetching application css and js..."
js=$(grep -P "/assets/mumuki_laboratory/application\-.*\.js" exercises/*.html -oh | head -n1)
css=$(grep -P "/assets/mumuki_laboratory/application\-.*\.css" exercises/*.html -oh | head -n1)

curl "http://localhost:3000$js" -s > assets/application.js
curl "http://localhost:3000$css" -s > assets/application.css

for i in exercises lessons chapters; do
  echo "[Murga] Replacing css and js references..."
  sed -i "s|$js|../assets/application.js|g" $i/*.html
  sed -i "s|$css|../assets/application.css|g" $i/*.html

  echo "[Murga] Removing turbolinks metadata..."
  sed -i 's|data-turbolinks-track="reload"||g' exercises/*.html
  sed -i 's|data-turbolinks="true"||g' exercises/*.html

  for i in theme_stylesheet extension_javascript; do
    echo "[Murga] Removing $i..."
    sed -i "s|.*$i.*||g" exercises/*.html
  done
done


echo "[Murga] Resolving exercises references..."
sed -i "s|/central/exercises/\([0-9]\+\)|\1.html#|g"               exercises/*.html
sed -i "s|/central/exercises/\([0-9]\+\)|../exercises/\1.html#|g"  lessons/*.html
sed -i "s|/central/exercises/\([0-9]\+\)|../exercises/\1.html#|g"  chapters/*.html

echo "[Murga] Resolving chapters references..."
sed -i "s|/central/chapters/\([0-9]\+\)|../chapters/\1.html#|g"    exercises/*.html
sed -i "s|/central/chapters/\([0-9]\+\)|../chapters/\1.html#|g"    lessons/*.html
sed -i "s|/central/chapters/\([0-9]\+\)|\1.html#|g"                chapters/*.html

echo "[Murga] Resolving lessons references..."
sed -i "s|/central/lessons/\([0-9]\+\)|../lessons/\1.html#|g"      exercises/*.html
sed -i "s|/central/lessons/\([0-9]\+\)|\1.html#|g"                 lessons/*.html
sed -i "s|/central/lessons/\([0-9]\+\)|../lessons/\1.html#|g"      chapters/*.html


echo "[Murga] Replacing Gobstones assets..."
for i in polymer.html gs-board.html \
         polymer-mini.html polymer-micro.html \
         runner.js offline.js \
         editor/editor.html editor/editor.css \
         editor/editor.js editor/hammer.min.js \
         editor/gobstones-code-runner.html \
         editor/gs-element-blockly.html \
         editor/attires_enabled.svg editor/attires_disabled.svg  \
         editor/red.svg editor/green.svg editor/blue.svg editor/black.svg; do
  file_name=$(basename $i)

  echo "[Murga] ...replacing $i"
  curl "http://localhost:9292/assets/$i" -s > assets/$file_name
  sed -i "s|http://localhost:9292/assets/$i|../assets/$file_name|g" exercises/*.html
done

echo "[Murga] Fetching fonts..."
for i in dev-awesome.woff2 fontawesome-webfont.woff2 fontawesome-webfont.ttf; do
  echo "[Murga] ...fetching $i"
  curl "http://localhost:3000/assets/$i" -s > assets/$i
  sed -i "s|/assets/$i|../assets/$i|g" assets/*.css
done

echo "[Murga] Fetching compass rose..."
curl "http://localhost:3000/compass_rose.svg" -s > assets/compass_rose.svg
sed -i "s|/compass_rose.svg|../assets/compass_rose.svg|g" exercises/*.html

echo "[Murga] Fetching characters..."
curl "http://localhost:3000/character/animations.json" -s > character/animations.json
for i in context failure jump success2_l success_l; do
  echo "[Murga] ...fetching kibi/$i"
  curl "http://localhost:3000/character/kibi/$i.svg" -s > character/kibi/$i.svg
done
for i in apparition loop; do
  echo "[Murga] ...fetching magnifying_glass/$i"
  curl "http://localhost:3000/character/magnifying_glass/$i.svg" -s > character/magnifying_glass/$i.svg
done
sed -i "s|/character/|../character/|g" assets/application.js

echo "[Murga] Fetching errors..."
for i in timeout_1 timeout_2 timeout_3; do
  echo "[Murga] ...fetching $i"
  curl "http://localhost:3000/error/$i.svg" -s > assets/$i.svg
done
sed -i "s|/error/|../assets/|g" assets/application.js
