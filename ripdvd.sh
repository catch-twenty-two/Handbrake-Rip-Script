#!/bin/bash

SEASON=1
EPISODE=1
EXTRACTION_PATH="/tmp/"
COPY_PATH="/run/user/1000/gvfs/afp-volume:host=192.168.2.151,user=jimmy,volume=video/TV show/"
#"/Volumes/video/TV show/"
FULL_TITLE="Unknown"

extract()
{
	echo "Exporting DVD to title $TITLE_NAME"
	
	for i in `seq $TITLE_COUNT`
	do	
		# Ex. King Of The Hill Season 3 S03-E06
		FULL_TITLE=$( printf "$TITLE_NAME Season $SEASON S%02d-E%02d.mp4" $SEASON $EPISODE )
		
		echo "Extracting $FULL_TITLE"
		
		if [ -f "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE" ]; then
			echo "File already exists skipping this title"
			EPISODE=`expr $EPISODE + 1`	
			continue
		fi
		
		HandBrakeCLI -i /dev/sr0 -t $i --min-duration 1140 --preset Normal -o "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE"

		INCREMENT=1

		find "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE" -name "$FULL_TITLE" -size -100M | grep "$FULL_TITLE"
		
		if [ "$?" = "0" ]; then 
			rm "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE"
			INCREMENT=0 
		fi

		find "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE" -name "$FULL_TITLE" -size +400M | grep "$FULL_TITLE"

		if [ "$?" = "0" ]; then 
			rm "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE"
			INCREMENT=0		
		fi
		
		if [ $INCREMENT = "1" ]; then 
			EPISODE=`expr $EPISODE + $INCREMENT`
			mkdir -p "$COPY_PATH$TITLE_NAME"
			cp "$EXTRACTION_PATH$TITLE_NAME/$FULL_TITLE" "$COPY_PATH$TITLE_NAME" &
		fi
	
	done
	
	echo "Disc Done!"
	
	eject /dev/sr0
}

while [ true ]; do
	
	echo "Please insert dvd and press p to enter parameters, x to exit or s to skip to immediate extraction using $FULL_TITLE"
	read -n 1 ANSWER
	
	if [ ! -z "$ANSWER" ] && [ "$ANSWER" = "x" ]; then
		exit 0
	fi
		
	mount | grep /dev/sr0 2>1 > /dev/null
	
	while [ $? = "1" ]; do
		echo "Searching for DVD..."
		sleep 1
		mount | grep /dev/sr0 2>1 > /dev/null		
	done

	sleep 4

	if [ ! -z "$ANSWER" ] && [ "$ANSWER" = "p" ]; then

	    echo "Reading Titles"	    
            HandBrakeCLI -i /dev/sr0 --title 0 --min-duration 1140 2> hb.out	    
            TITLE_COUNT=$( cat hb.out | grep -cw "+ title" )	
            rm hb.out	    
            echo "Found $TITLE_COUNT titles"

        fi
	
	if [ ! -z "$ANSWER" ] && [ "$ANSWER" = "s" ]; then
		extract
		continue
	fi
	
	echo "Title name (return for $TITLE_NAME)"
	
	read ANSWER
	
	if [ ! -z "$ANSWER" ]
	then
		TITLE_NAME=$ANSWER
	fi
	
	if [ ! -d "$EXTRACTION_PATH$TITLE_NAME" ]
	then
		echo "Directory for $TITLE_NAME not found, create? (y/n)"
		read -n 1 ANSWER
		
		if [ ! -z "$ANSWER" ] && [ $ANSWER = "y" ]; then
			mkdir -p "$EXTRACTION_PATH$TITLE_NAME"	
		else
			echo "Can't start script without episode folder"
			exit 1
		fi
				
	fi
	
	echo "Season (return for $SEASON)"	
	read ANSWER
	
	if [ ! -z "$ANSWER" ]	
	then
		SEASON=$ANSWER
	fi

	echo "Episode offset (return for $EPISODE)"
	read ANSWER

	if [ ! -z "$ANSWER" ]	
	then
		EPISODE=$ANSWER
	fi	

	extract

done
