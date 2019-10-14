# Building primaria

1. Go to `/offline-primaria`
2. Run `./fetch.sh`
3. Check `google-chrome contents/1715.html -allow-file-access-from-files --allow-file-access --allow-cross-origin-auth-prompt`

# Building secundaria

1. Go to `/offline`
2. Run `./fetch.sh`
3. Check `google-chrome contents/795.html -allow-file-access-from-files --allow-file-access --allow-cross-origin-auth-prompt`

# Building all

1. Run `./build.sh`
2. Check `google-chrome primara/1715.html -allow-file-access-from-files --allow-file-access --allow-cross-origin-auth-prompt`

# Running

1. Run `npm install`
2. Run `./build.sh`
3. Run `npm start`

# Packaging

1. Run `npm install electron-packager -g`
2. Run `electron-packager . --overwrite`
3. Run `./cumparsita-linux-x64/cumparsita`
