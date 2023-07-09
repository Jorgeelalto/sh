# https://stackoverflow.com/questions/32062159/how-retrieve-the-creation-date-of-photos-with-a-script

if [ $# -ne 1 ]; then
	echo "Invalid number of arguments."
	echo "Usage: rename_pics.sh <file_format>"
	exit 1
fi

echo "Renaming all $1 pictures..."
for FILE in $(ls | grep "$1"); do
	DATEBITS=( $(exiftool -CreateDate -FileModifyDate -DateTimeOriginal "$FILE" | awk -F: '{ print $2 ":" $3 ":" $4 ":" $5 ":" $6 }' | sed 's/+[0-9]*//' | sort | grep -v 1970: | cut -d: -f1-6 | tr ':' ' ' | head -1) )
	FORMAT="$(echo "${FILE##*.}")"
	NEWNAME="IMG_${DATEBITS[0]}${DATEBITS[1]}${DATEBITS[2]}_${DATEBITS[3]}${DATEBITS[4]}${DATEBITS[5]}"
	if [ ! ${#NEWNAME} -eq 19 ]; then
		echo "Filename potentially incorrect: $NEWNAME"
		echo "Might not have correct EXIF data if at all. Name will not be modified."
	else
		NEWNAME="$NEWNAME.$FORMAT"
		echo "Renaming $FILE to $NEWNAME"
		mv $FILE $NEWNAME
	fi
done
echo "Done!"
