SEASON=1
EPISODE=1
EXTRACTION_PATH="/Volumes/video/TV show/"

while [ true ]; do
	
	echo "Please insert dvd and press enter press x to exit"
	read ANSWER
	
	if [ $ANSWER = "x" ]; then
		exit 1	
	fi
		
	file /dev/disk1 > /dev/null
	
	while [ $? = "1" ]; do
		echo "Searching for DVD..."
		sleep 1
		file /dev/disk1	> /dev/null		
	done
	
	echo "Reading Titles"
	
	HandBrakeCLI -i /dev/disk1 --title 0 2> hb.out

	TITLE_COUNT=$( cat hb.out | grep -cw "+ title" )

	rm hb.out

	echo "Found $TITLE_COUNT titles"
	echo "Title name (return for) $TITLE_NAME"
	
	read ANSWER
	
	if [ ! -z "$ANSWER" ]
	then
		TITLE_NAME=$ANSWER
	fi
	
	if [ -d "$EXTRACTION_PATH$TITLE_NAME" ]
	then
		echo "Directory for $TITLE_NAME not found, create?"
		read ANSWER
		
		if [ $ANSWER = "y" ]; then
			mkdir -p "$EXTRACTION_PATH$TITLE_NAME"	
		fi
		
	done
	
	echo "Season (return for) $SEASON"	
	read ANSWER
	
	if [ ! -z "$ANSWER" ]	
	then
		SEASON=$ANSWER
	fi

	echo "Episode offset (return for) $EPISODE"
	read ANSWER

	if [ ! -z "$ANSWER" ]	
	then
		EPISODE=$ANSWER
	fi	

	echo "Exporting DVD to title $TITLE_NAME"
	
	for i in `seq $TITLE_COUNT`
	do	
		# Ex. King Of The Hill Season 3 S03-E06
		FULL_TITLE=$( printf "$TITLE_NAME Season $SEASON S%02d-E%02d.mp4" $SEASON $EPISODE )
		
		echo "Extracting $FULL_TITLE"
		
		HandBrakeCLI -i /dev/disk1 -t $i --preset Normal -o "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE"
		EPISODE=`expr $EPISODE + 1`		
	done
	
	EPISODE=`expr $EPISODE + 1`	
	
	echo "Disc Done!"
	
	diskutil eject /dev/disk1
	
done
