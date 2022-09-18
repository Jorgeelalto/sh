for f in *.flac; do
    ffmpeg -i "$f" -ab 320k -map_metadata 0 -id3v2_version 3 "${f%.flac}".mp3;
done

echo "Do you want to remove the original .flac files?"
read -n 1 reply
if [ $reply = "y" ]; then
    rm *.flac
fi
