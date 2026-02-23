mkdir -p .previews

for f in *; do
  [ -f "$f" ] || continue
  [ -L "$f" ] && continue

  tmp=$(mktemp -d)

  xcur2png --directory "$tmp" "$f" 2>/dev/null

  png=$(ls "$tmp"/*.png 2>/dev/null | head -n 1)
  if [ -n "$png" ]; then
    cp "$png" ".previews/$f.png"
  fi

  rm -rf "$tmp"
done
