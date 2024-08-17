# Regular key to Camelot table
CAMELOT_TABLE=(
    'B=1B' \
    'Gb=2B' \
    'F#=2B' \
    'Db=3B' \
    'Ab=4B' \
    'G#=4B' \
    'Eb=5B' \
    'D#=5B' \
    'Bb=6B' \
    'F=7B' \
    'C=8B' \
    'G=9B' \
    'D=10B' \
    'A=11B' \
    'E=12B' \
    'G#m=1A' \
    'Abm=1A' \
    'Ebm=2A' \
    'Bbm=3A' \
    'A#m=3A' \
    'Fm=4A' \
    'Cm=5A' \
    'Gm=6A' \
    'Dm=7A' \
    'Am=8A' \
    'Em=9A' \
    'Bm=10A' \
    'F#m=11A' \
    'C#m=12A' \
    'Dbm=12A' \
)


# Start
echo "Checking all .mp3 files in $(pwd)..."

find . -type f -name "*.mp3" -print0 | while IFS= read -r -d '' FILE; do

    echo && echo

    # Get data
    KEY=$(mid3v2 --list "$FILE" | grep "TKEY=" | cut -c 6-)
    TITLE=$(mid3v2 --list "$FILE" | grep "TIT2=" | cut -c 6-)
    # Print basic data
    echo "-> $FILE, TIT2=\"$TITLE\", TKEY=\"$KEY\""

    IS_THERE_KEY_IN_TAG="false"
    IS_KEY_IN_TAG_CAMELOT=$([[ "$KEY" =~ ^[1-9][0-2]?[AB] ]] && echo "true" || echo "false")
    IS_THERE_KEY_IN_TITLE="false"

    # Check if the key is in the title
    if [[ "$TITLE" =~ ^[1-9][0-2]?[AB]\ - ]]; then
        if ! [[ -z "$KEY" ]]; then
            echo "    i Found key in title, nothing to do"
            continue
        else
            # Store the key from the title
            KEY=$(echo $TITLE | cut -c -3 | xargs)
            echo "    i Found key in title: $KEY"
            IS_THERE_KEY_IN_TITLE="true"
        fi
    else
        echo "    x No key found in title"
    fi

    # Check if the key is in the tags
    if [[ -z "$KEY" ]]; then
        echo "    x No key found in tags"
    else
        echo "    i Found key in tags: $KEY"
        IS_THERE_KEY_IN_TAG="true"
        if [ "$IS_KEY_IN_TAG_CAMELOT" = "false" ] ; then
            echo "    x Key in tags is not in Camelot format"
        fi
    fi


    # If there is no key information, nothing to do
    if [ "$IS_THERE_KEY_IN_TAG" = "false" ] && [ "$IS_THERE_KEY_IN_TITLE" = "false" ]; then
        echo "    x No key information so nothing to do"
        continue
    fi

    # If key is not in Camelot, change it
    if [ "$IS_KEY_IN_TAG_CAMELOT" = "false" ]; then
        NEW_KEY=""
        for ITEM in ${CAMELOT_TABLE[@]}; do
            if ! [[ -z $(echo $ITEM | grep "$KEY") ]]; then
                NEW_KEY=$(echo $ITEM | grep "$KEY" | cut -d"=" -f2)
                break
            fi
        done
        echo "    i Key will be changed from $KEY to $NEW_KEY"
        KEY=$NEW_KEY
    fi


    # Now we have the correct key, transformed into Camelot (if it was needed),
    # extracted either from the tag (higher priority) or from the title. We also
    # know that the key is not in the title.
    # 
    # We need to write the key to the title, and if it was not in camelot, also
    # to the tag.

    if [ "$IS_KEY_IN_TAG_CAMELOT" = "false" ]; then
        echo "    > Writing new tag"
        echo "      TKEY=\"$KEY\""
        mid3v2 --TKEY "$KEY" "$FILE"
    fi

    if [ "$IS_THERE_KEY_IN_TITLE" = "false" ]; then
        echo "    > Writing new title"
        TITLE="$KEY - $TITLE"
        echo "      TIT2=\"$TITLE\""
        mid3v2 --TIT2 "$TITLE" "$FILE"
    fi
done

echo
echo "Done"
