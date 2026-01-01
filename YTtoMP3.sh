source ~/Venvs/yt-dlp/bin/activate
yt-dlp -x --audio-format mp3 --prefer-ffmpeg "$1" --audio-quality 320K
deactivate

