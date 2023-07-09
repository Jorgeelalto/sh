# https://stackoverflow.com/questions/32062159/how-retrieve-the-creation-date-of-photos-with-a-script
# https://stackoverflow.com/a/965069

if [ $# -ne 2 ]; then
	echo "Invalid number of arguments."
	echo "Usage: rename_pics.sh <force_rename: yes/no> <file_format>"
	exit 1
fi

echo "Renaming all $2 pictures..."
for FILE in $(ls | grep "$2"); do
	# Skip if the name format is already the one we need
	if [ ! "$1" = "yes" ]; then
		if [[ ${FILE%%.*} =~ ^IMG_[0-9]{8}_[0-9]{6}$ ]]; then
			echo "$FILE is already in the format we want. Skipping..."
			continue
		fi
	fi
	DATEBITS=( $(exiftool -CreateDate -FileModifyDate -DateTimeOriginal "$FILE" | awk -F: '{ print $2 ":" $3 ":" $4 ":" $5 ":" $6 }' | sed 's/+[0-9]*//' | sort | grep -v 1970: | cut -d: -f1-6 | tr ':' ' ' | head -1) )
	FORMAT="$(echo "${FILE##*.}")"
	NEWNAME="IMG_${DATEBITS[0]}${DATEBITS[1]}${DATEBITS[2]}_${DATEBITS[3]}${DATEBITS[4]}${DATEBITS[5]}"
	if [ ${#NEWNAME} -ne 19 ]; then
		echo "Filename potentially incorrect: $NEWNAME"
		echo "Might not have correct EXIF data if at all. Name will not be modified."
	else
		NEWNAME="$NEWNAME.$FORMAT"
		if [ -f "$NEWNAME" ]; then
			echo "File with the same name already exists! Skipping..."
			continue
		fi
		echo "Renaming $FILE to $NEWNAME"
		mv $FILE $NEWNAME
	fi
done
echo "Done!"
