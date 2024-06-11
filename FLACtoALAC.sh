for f in *.flac; do
    ffmpeg -i "$f" -y -vn -c:v copy -c:a alac "${f%.flac}".m4a;
done

echo "Do you want to remove the original .flac files?"
read -n 1 reply
if [ $reply = "y" ]; then
    rm *.flac
fi
