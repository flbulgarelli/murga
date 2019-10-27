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
    pushd $repo
    $install_script
    popd
  fi

  echo "[Murga] Checking whether $repo is running..."
  if ! lsof -i :$port; then
    echo "[Murga] ... $repo is down. Staring it up..."
    pushd $repo
    $start_script >/dev/null 2>&1 &
    popd

    echo "[Murga] Waiting $repo to start..."
    sleep 10
  fi
  popd
}

function on_exit() {
  echo '[Murga] Killing danling jobs'
  for i in $(jobs -p); do
    echo "[Murga] Killing process $i..."
    kill $i
  done
}

curl_opts="-sL"

function fetch() {
  curl "$1" $curl_opts > "$2"
}

function fetch_content() {
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
                                        --compressed $curl_opts > $destination

}

function scrap_content_assets() {
  regexp=$1
  preffix=$2
  extension=$3
  content_dirs="exercises/*.html lessons/*.html chapters/*.html books/*.html assets/attires*.json"
  for i in $(grep $regexp $content_dirs -PRoh | sort | uniq); do
    filename=$(to_hashed_filename $i $preffix $extension)

    echo "[Murga] ...fetching $i as $filename"
    fetch $i assets/$filename
    sed -i "s|$i|../assets/$filename|g" $content_dirs
  done
}

function to_hashed_filename() {
  url=$1
  preffix=$2
  extension=$3
  hash=$(echo $1 | md5sum | awk '{print $1}')
  echo ${preffix}_${hash}.${extension}
}

############
## Script ##
############

trap on_exit EXIT

clone_and_start 'gobstones-runner' 'bundle install' 'bundle exec rackup' 9292
clone_and_start laboratory ./devinit ./devstart 3000

echo "[Murga] Fetching exercises..."
for i in {1..139}; do
  echo "[Murga] ...fetching exercise $i"
  fetch_content "central/exercises/$i" "exercises/$i.html"
done

echo "[Murga] Fetching lessons..."

for i in {1..14}; do
  echo "[Murga] ...fetching lessons $i"
  fetch_content "central/lessons/$i" "lessons/$i.html"
done

echo "[Murga] Fetching chapters..."

for i in {1..7}; do
  echo "[Murga] ...fetching chapters $i"
  fetch_content "central/chapters/$i" "chapters/$i.html"
done

echo "[Murga] ...fetching book 1"
fetch_content "central/books/1" "books/1.html"

echo "[Murga] Fetching application css and js..."
js=$(grep -P "/assets/mumuki_laboratory/application\-.*\.js" exercises/*.html -oh | head -n1)
css=$(grep -P "/assets/mumuki_laboratory/application\-.*\.css" exercises/*.html -oh | head -n1)

fetch "http://localhost:3000$js" assets/application.js
fetch "http://localhost:3000$css" assets/application.css

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
    sed -i "s|.*$i.*||g" lessons/*.html
    sed -i "s|.*$i.*||g" chapters/*.html
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
  filename=$(basename $i)

  echo "[Murga] ...replacing $i"
  fetch "http://localhost:9292/assets/$i" assets/$filename
  sed -i "s|http://localhost:9292/assets/$i|../assets/$filename|g" exercises/*.html
  sed -i "s|http://localhost:9292/assets/$i|../assets/$filename|g" lessons/*.html
done

echo "[Murga] Fetching fonts..."
for i in dev-awesome.woff2 fontawesome-webfont.woff2 fontawesome-webfont.ttf; do
  echo "[Murga] ...fetching $i"
  fetch "http://localhost:3000/assets/$i" assets/$i
  sed -i "s|/assets/$i|../assets/$i|g" assets/*.css
done

echo "[Murga] Fetching Google fonts"
fetch "https://fonts.googleapis.com/css?family=Lato:400,700,400italic" assets/googlefonts.css
fetch "https://fonts.gstatic.com/s/lato/v16/S6uyw4BMUTPHjx4wWw.ttf"    assets/lato-regular.ttf
fetch "https://fonts.gstatic.com/s/lato/v16/S6u8w4BMUTPHjxsAXC-v.ttf"  assets/lato-italic.ttf

sed -i "s|https://fonts.googleapis.com/css?family=Lato:400,700,400italic|../assets/googlefonts.css|g" assets/*.css
sed -i "s|https://fonts.gstatic.com/s/lato/v16/S6uyw4BMUTPHjx4wWw.ttf|../assets/lato-regular.ttf|g"   assets/*.css
sed -i "s|https://fonts.gstatic.com/s/lato/v16/S6u8w4BMUTPHjxsAXC-v.ttf|../assets/lato-italic.ttf|g"  assets/*.css

echo "[Murga] Fetching compass rose..."
fetch "http://localhost:3000/compass_rose.svg" assets/compass_rose.svg
sed -i "s|/compass_rose.svg|../assets/compass_rose.svg|g" exercises/*.html

echo "[Murga] Fetching characters..."
fetch "http://localhost:3000/character/animations.json" character/animations.json
for i in context failure jump success2_l success_l; do
  echo "[Murga] ...fetching kibi/$i"
  fetch "http://localhost:3000/character/kibi/$i.svg" character/kibi/$i.svg
done
for i in apparition loop; do
  echo "[Murga] ...fetching magnifying_glass/$i"
  fetch "http://localhost:3000/character/magnifying_glass/$i.svg" character/magnifying_glass/$i.svg
done
sed -i "s|/character/|../character/|g" assets/application.js

echo "[Murga] Fetching errors..."
for i in timeout_1 timeout_2 timeout_3; do
  echo "[Murga] ...fetching $i"
  fetch "http://localhost:3000/error/$i.svg" assets/$i.svg
done
sed -i "s|/error/|../assets/|g" assets/application.js

echo "[Murga] Fetching blockly-package assets..."
for i in click.mp3 delete.mp3 disconnect.wav sprites.png; do
  echo "[Murga] ...fetching $i"
  fetch "https://github.com/Program-AR/blockly-package/raw/v0.0.15/media/$i" assets/$i
done
sed -i "s|https://github.com/Program-AR/blockly-package/raw/v0.0.15/media/|../assets/|g" assets/editor.html


echo "[Murga] Fetching blockly-package assets..."
for i in color-verde color-negro color-azul color-rojo \
         direccion-este direccion-norte direccion-oeste direccion-sur \
         bool-true bool-false; do
  echo "[Murga] ...fetching $i"
  fetch "https://github.com/Program-AR/gs-element-blockly/raw/0.19.1/media/$i.svg?sanitize=true" assets/$i.svg
done
sed -i "s|https://github.com/Program-AR/gs-element-blockly/raw/0.19.1/media/|../assets/|g" assets/editor.html



echo "[Murga] Fetching toolboxes..."
scrap_content_assets "https://raw.githubusercontent.com/MumukiProject/[^/]+/master/assets/attires/config(_.+)?\.json" "attires" "json"

echo "[Murga] Fetching attires..."
scrap_content_assets "https://raw.githubusercontent.com/MumukiProject/[^/]+/master/assets/toolbox(_.+)?\.xml" "toolbox" "xml"

echo "[Murga] Fetching static content assets..."
scrap_content_assets "https://mumuki.io/static/for_content/[^/]+\.svg" "static_content" "svg"

echo "[Murga] Fetching attires images..."
scrap_content_assets 'https://raw.githubusercontent.com/MumukiProject/[^/]+/master/assets/[^"]*\.png' "attire_image" "png"
