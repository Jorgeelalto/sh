# https://stackoverflow.com/questions/32062159/how-retrieve-the-creation-date-of-photos-with-a-script
# https://stackoverflow.com/a/965069


# This script renames every file with a certain extension in the current folder
# to the format IMG_YYYYMMDD_HHMMSS. Without the force_rename flag set to "yes",
# the script will skip files that already comply with that filename format.

# TODO: handle the case where the EXIF shows the same time (down to the second, which happens often)


if [ $# -ne 2 ]; then
	echo "Invalid number of arguments."
	echo "Usage: rename_pics.sh <force_rename: yes/no> <file_format (case insensitive!)>"
	exit 1
fi

echo "Renaming all $2 pictures..."
for FILE in $(ls | grep -i "$2"); do
	# Skip if the name format is already the one we need
	if [ ! "$1" = "yes" ]; then
		if [[ ${FILE%%.*} =~ ^IMG_[0-9]{8}_[0-9]{6}$ ]]; then
			echo "$FILE is already in the format we want. Skipping..."
			continue
		fi
	fi
	# Extract the date info from the EXIF in the pic
	DATEBITS=( $(exiftool -CreateDate -FileModifyDate -DateTimeOriginal "$FILE" | awk -F: '{ print $2 ":" $3 ":" $4 ":" $5 ":" $6 }' | sed 's/+[0-9]*//' | sort | grep -v 1970: | cut -d: -f1-6 | tr ':' ' ' | head -1) )
	# Get the file original extension (format)
	FORMAT="$(echo "${FILE##*.}")"
	# Compose the new filename (without the extension)
	NEWNAME="IMG_${DATEBITS[0]}${DATEBITS[1]}${DATEBITS[2]}_${DATEBITS[3]}${DATEBITS[4]}${DATEBITS[5]}"
	# If it is malformed already is because the EXIF is not OK
	if [ ${#NEWNAME} -ne 19 ]; then
		echo "Filename potentially incorrect: $NEWNAME"
		echo "Might not have correct EXIF data if at all. Name will not be modified."
	else
		# Compose the final filename
		FORMAT=$(echo $FORMAT | awk '{print tolower($0)}')
		NEWNAME="$NEWNAME.$FORMAT"
		# If it already exists then there are several pics with the same EXIF (incorrect)
		if [ -f "$NEWNAME" ]; then
			echo "File with the same name already exists!"
			echo "$FILE -> $NEWNAME"
			echo "Skipping..."
			continue
		fi
		echo "Renaming $FILE to $NEWNAME"
		mv $FILE $NEWNAME
	fi
done
echo "Done!"
