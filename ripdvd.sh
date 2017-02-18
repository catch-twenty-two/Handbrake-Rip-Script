#!/bin/bash

SEASON=1
EPISODE=1
EXTRACTION_PATH="/tmp"
COPY_PATH="/volume1/video"
FULL_TITLE="Unknown"
#only extract videos between the follow durations
TIME_LOWER_LIMIT=18
TIME_UPPER_LIMIT=24

extract()
{
    echo "Exporting DVD to title $TITLE_NAME"
    
    for i in `seq $TITLE_COUNT`
    do    
        TITLE_DURATION=$( cat hb.out | grep -A 2 -w "scanning title $i" | grep -w "scan: duration is" | gawk '{print substr($6,2)}' )

        if [ `expr $TITLE_DURATION / 1000 / 60` -gt "$TIME_LOWER_LIMIT" ] && [ `expr $TITLE_DURATION / 1000 / 60` -lt "$TIME_UPPER_LIMIT" ]
        then 
            # Ex. King Of The Hill Season 3 S03-E06
            FULL_TITLE=$( printf "$TITLE_NAME Season $SEASON S%02d-E%02d.mp4" $SEASON $EPISODE )
        
            echo "Extracting $FULL_TITLE"      
            
            if [ -f "$EXTRACTION_PATH/$TITLE_NAME/$FULL_TITLE" ]; then
                echo "File already exists skipping this title"
            else
                HandBrakeCLI -i /dev/sr0 -t $i --preset Normal -o "$EXTRACTION_PATH/$TITLE_NAME/$FULL_TITLE"
            fi

            EPISODE=`expr $EPISODE + 1`

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
            HandBrakeCLI -i /dev/sr0 --title 0 2> hb.out        
            TITLE_COUNT=$( cat hb.out | grep -cw "+ title" )        
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
    
    if [ ! -d "$EXTRACTION_PATH/$TITLE_NAME" ]
    then
        echo "Directory for $TITLE_NAME not found, create? (y/n)"
        read -n 1 ANSWER
        
        if [ ! -z "$ANSWER" ] && [ $ANSWER = "y" ]; then
            mkdir -p "$EXTRACTION_PATH/$TITLE_NAME"    
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
