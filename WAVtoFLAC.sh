if [ "$1" = "n" ]; then
	echo "Keep original files mode"
	find . -name '*.wav' | while read LINE; do flac -5 "$LINE"; done
	exit 0
fi

if [ "$1" = "y" ]; then
	echo "Remove files mode"
	find . -name '*.wav' | while read LINE; do flac -5 "$LINE" && rm "$LINE"; done
	exit 0
fi

echo "Invalid removal argument. Please specify whether to remove original WAV file. Usage:"
echo "    ./WAVtoFLAC.sh [y/n]"
exit 1