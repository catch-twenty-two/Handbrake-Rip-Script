SEASON=1
EPISODE=1

while [ true ]; do
	
	echo "Please insert dvd and press enter"
	read
	
	echo "Reading Titles"
	
	HandBrakeCLI -i /dev/disk1 --title 0 2> hb.out

	TITLE_COUNT=$( cat hb.out | grep -cw "+ title" )

	rm hb.out

	echo "Found $TITLE_COUNT titles"
	echo "Title name (return for) $TITLE_NAME"
	
	read ANSWER

	if [ ! -z "$ANSWER" ]
	then
#		ANSWER=$( echo $ANSWER | sed 's/\ /\\ /g'  )
		TITLE_NAME=$ANSWER
	fi
	
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
		FULL_TITLE=$( printf "$TITLE_NAME Season $SEASON S-%02d E-%02d.mp4" $SEASON $EPISODE )
		echo "Extracting $FULL_TITLE"
		HandBrakeCLI -i /dev/disk1 -t $i --preset Normal -o "$FULL_TITLE"
		EPISODE=`expr $EPISODE + 1`		
	done
	
	EPISODE=`expr $$TITLE_COUNT + 1`	
	
	echo "Done!"
	
	diskutil eject /dev/disk1
	
done
