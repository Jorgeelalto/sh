find . \( -iname "*.flac" -o -iname "*.mp3" \) -exec rsgain custom --skip-existing --tagmode=i '{}' \;
