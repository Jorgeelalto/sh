source ~/Venvs/yt-dlp/bin/activate
yt-dlp -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]' $1
deactivate

