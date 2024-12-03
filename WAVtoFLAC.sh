for f in *.wav; do
    flac -5 "$f";
done

echo "Do you want to remove the original .wav files? [y/n]"
read -n 1 reply
if [ $reply = "y" ]; then
    rm *.wav
fi
