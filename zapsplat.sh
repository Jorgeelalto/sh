mkdir Zapsplat
cd Zapsplat

# Get list of categories
curl -s https://www.zapsplat.com/sound-effect-categories/ > categories
grep -A 2 "top-level-cat-item" categories | grep "href=https://www.zapsplat.com/sound-effect-category/" | sed "s/href=//" | sed "s/ .*//" > cat_links
rm categories


# Now, check each category for subcategories
for i in $(cat cat_links); do

	# Get name of the category
	CAT_NAME=$(echo ${i%?} | sed "s/.*\///g")
	echo "> Processing category $CAT_NAME"
	# Create its folder and get in it
	mkdir $CAT_NAME
	cd $CAT_NAME
	# Now get the subcategories
	curl -s $i > subcategories
	grep -A 2 "cat-item" subcategories | grep "href=https://www.zapsplat.com/sound-effect-category/" | sed "s/href=//" | sed "s/ .*//" > subcat_links
	rm subcategories

	# Now, for every subcategory do the same
	for j in $(cat subcat_links); do
		# Get the name of the subcategory
		SUBCAT_NAME=$(echo ${j%?} | sed "s/.*\///g")
		echo "  > Processing subcategory $SUBCAT_NAME"
		# Create its folder and get in it
		mkdir $SUBCAT_NAME
		cd $SUBCAT_NAME
		# Now get the list of files
		# In which page of the subcategory are we?
		PAGE=1
		# While we didn't get to the end of the category (a page that does not exist)
		while [ 1 ]; do
			echo "        > Checking page $PAGE"
			# Get the page link (different when we are in the first page)
			if [ $PAGE -eq 1 ]; then
				LINK="$j"
			else
				LINK=${j}page/$PAGE/
			fi
			# Try to get the page
			touch links
			curl -s $LINK > page
			# If the curl doesn't work, then we finished in this subcategory
			if [ "$(grep "/music/" page)" == "" ]; then
				echo "    > Got to the end of the subcategory, page $PAGE does not exist"
				rm page
				break
			fi
			# If it worked, we have to get the sound links
			grep -A 2 "class=sound-effect-title>" page | grep "href=https://www.zapsplat.com/music/" | sed "s/href=//" | sed "s/ .*//" >> links
			rm page
			PAGE=$(($PAGE + 1))
		done
		cd ..

	done

	# When finish, go to the categories folder
	cd ..

done


cd ..