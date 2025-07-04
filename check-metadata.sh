echo "Running metadata check..."

for file in content/*.html; do
  echo "Checking $file"
  missing=""
  grep -q "<title>" "$file" || missing="$missing title"
  grep -q 'meta name="description"' "$file" || missing="$missing description"
  grep -q 'property="og:image"' "$file" || missing="$missing og:image"

  if [ ! -z "$missing" ]; then
    echo "$file is missing:$missing"
    exit 1
  else
    echo "$file has all required meta tags"
  fi

done