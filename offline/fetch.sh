#!/bin/bash

set -e

rm -rf contents
rm -rf assets
mkdir assets
mkdir contents

echo "[Ikumi::Offline] Fetching exercises..."
for i in {795..808}; do
  echo "[Ikumi::Offline] ...fetching exercise $i"
  curl "http://localhost:3000/central/exercises/$i" -H 'Connection: keep-alive' \
                                                    -H 'Pragma: no-cache' \
                                                    -H 'Cache-Control: no-cache' \
                                                    -H 'Upgrade-Insecure-Requests: 1' \
                                                    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.75 Safari/537.36' \
                                                    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
                                                    -H 'Accept-Encoding: gzip, deflate, br' \
                                                    -H 'Accept-Language: en-US,en;q=0.9,es;q=0.8' \
                                                    -H 'Cookie: login_organization=central; mucookie_session=N3pqbFhjbjlIWExmeFJMQ2xlK1N3NVhNQ0ZFZjdjemlBSHhNYVhySGk2az0tLWw1c1QwRUMxTnlIdVFmRjZ3ZEh3N0E9PQ%3D%3D--7a433a3f9284f53eba1c175ef8a5a4633c665222; mucookie_profile=eyJ1c2VyX25hbWUiOiIgIiwidXNlcl9pbWFnZV91cmwiOiJ1c2VyX3NoYXBl%0ALnBuZyJ9%0A; _mumuki_laboratory_session=MWhab3ZqTS9HOEUrY1h4aTZlTWM4UHU0VjlrMnlBcUVwRWtJdk01Nzk2R21MZFM1WW14M0txRGxkWGs2TnNsVmlBUGNoMThYblZ1K1N5WW4zS09WSytJUFRFNGJ1QXZJNGdIbUd0a0VvaFg1MTJWMWpjTG0veFdaZTQ5bEpySVlocFBiMWNZMXJkOE1QUFdIZ082MjZ3PT0tLWJJTEFYbkpROFZIK3dqYlg5TWFRbEE9PQ%3D%3D--6e6de6549a844c9e0b713629544fa102cace8ac2' \
                                                    --compressed -s > contents/$i.html
done

echo "[Ikumi::Offline] Fetching application css and js..."
js=$(grep -P "/assets/mumuki_laboratory/application\-.*\.js" contents/*.html -oh | head -n1)
css=$(grep -P "/assets/mumuki_laboratory/application\-.*\.css" contents/*.html -oh | head -n1)

curl "http://localhost:3000$js" -s > assets/application.js
curl "http://localhost:3000$css" -s > assets/application.css

sed -i "s|$js|../assets/application.js|g" contents/*.html
sed -i "s|$css|../assets/application.css|g" contents/*.html

echo "[Ikumi::Offline] Removing turbolinks metadata..."
sed -i 's|data-turbolinks-track="reload"||g' contents/*.html
sed -i 's|data-turbolinks="true"||g' contents/*.html

for i in theme_stylesheet extension_javascript; do
  echo "[Ikumi::Offline] Removing $i..."
  sed -i "s|.*$i.*||g" contents/*.html
done

echo "[Ikumi::Offline] Resolving exercse references..."
sed -i "s|/central/exercises/\([0-9][0-9][0-9]\)|\1.html#|g" contents/*.html

echo "[Ikumi::Offline] Replacing Gobstones assets..."
for i in polymer gs-board polymer-mini polymer-micro local runner; do
  echo "[Ikumi::Offline] ...replacing $i.html"
  curl "http://localhost:9292/assets/$i.html" -s > assets/$i.html
  sed -i "s|http://localhost:9292/assets/$i.html|../assets/$i.html|g" contents/*.html
done

echo "[Ikumi::Offline] Fetching fonts..."
for i in dev-awesome.woff2 fontawesome-webfont.woff2 fontawesome-webfont.ttf; do
  echo "[Ikumi::Offline] ...fetching $i..."
  curl "http://localhost:3000/assets/$i" -s > assets/$i
  sed -i "s|/assets/$i|../assets/$i|g" assets/*.css
done

