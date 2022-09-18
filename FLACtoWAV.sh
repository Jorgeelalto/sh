if [ "$1" = "n" ]; then
	echo "Keep original files mode"
	find . -name '*.flac' | while read LINE; do flac -d "$LINE"; done
	exit 0
fi

if [ "$1" = "y" ]; then
	echo "Remove files mode"
	find . -name '*.flac' | while read LINE; do flac -d "$LINE" && rm "$LINE"; done
	exit 0
fi

echo "Invalid removal argument. Please specify whether to remove original FLAC file. Usage:"
echo "    ./FLACtoWAV.sh [y/n]"
exit 1