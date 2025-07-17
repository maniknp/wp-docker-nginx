#!/bin/bash

WATCH_DIRS=(
  "/var/www/public/wp-content/themes"
  "/var/www/public/wp-content/plugins"
  "/var/www/public/wp-content/cache"
  "/var/www/public/wp-content/uploads"
)



# Allowed extensions (you can expand this list)
EXTENSIONS=("png" "jpg" "jpeg" "webp" "html" "js" "css")

# Convert array to regex pattern: .*\.(png|jpg|jpeg|...)
EXT_REGEX=".*\.($(IFS=\|; echo "${EXTENSIONS[*]}"))$"

echo "📡 Watching for changes in:"
for dir in "${WATCH_DIRS[@]}"; do
  echo "  ➤ $dir"
done
echo "  🔍 Extensions: ${EXTENSIONS[*]}"

# Start watching
inotifywait -m -r \
  --timefmt '%Y-%m-%d %H:%M:%S' \
  --format '%T|%e|%w%f' \
  -e modify -e create -e delete \
  "${WATCH_DIRS[@]}" | while IFS='|' read -r timestamp event fullpath
do
  # Skip if it's a directory
  [[ -d "$fullpath" ]] && continue

  # Skip Brotli files
  [[ "$fullpath" == *.br ]] && continue

  # Match only selected extensions
  if [[ ! "$fullpath" =~ $EXT_REGEX ]]; then
    continue
  fi

  echo "[$timestamp] Event: $event on file: $fullpath"

  brfile="${fullpath}.br"

  if [[ "$event" == *CREATE* ]]; then
    echo "➡️  Compressing (level 6): $fullpath"
    brotli -f -q 6 "$fullpath" && echo "✅ Compressed: $brfile"

  elif [[ "$event" == *MODIFY* ]]; then
    echo "➡️  Recompressing (level 11): $fullpath"
    brotli -f -q 11 "$fullpath" && echo "✅ Recompressed: $brfile"

  elif [[ "$event" == *DELETE* ]]; then
    if [[ -f "$brfile" ]]; then
      echo "🗑️  Deleting compressed file: $brfile"
      rm -f "$brfile" && echo "✅ Deleted: $brfile"
    fi
  fi
done


# exec "$@"