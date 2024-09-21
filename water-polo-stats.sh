#!/bin/bash

echo "TEAM,LEVEL,PLACING,GOALS_FOR_PER_GAME,GOALS_AGAINST_AGAINST_PER_GAME,POINT_DELTA,COMP_RANK,WINS,LOSSES,TIES"

IFS='
'
TEAMS=""
for i in $(cat $1); do
    WHITE=$(echo $i | awk -F',' '{print $1}')
    DARK=$(echo $i | awk -F',' '{print $3}')
    TEAMS="$WHITE
$DARK
$TEAMS"
done

for TEAM in $(echo "$TEAMS" | sort -u); do
    if [ "$TEAM" = "" ]; then
        continue
    fi
    GOALS_FOR=0
    GOALS_AGAINST=0
    GAME_COUNT=0
    COMP_RANK=0
    WINS=0
    LOSSES=0
    TIES=0
    TIE_WINS=0
    TIE_LOSSES=0

    for SCORE in $(cat $1 | grep "$TEAM"); do
        WHITE=$(echo "$SCORE" | awk -F',' '{print $1}')
        DARK=$(echo "$SCORE" | awk -F',' '{print $3}')    
        WHITE_SCORE=$(echo "$SCORE" | awk -F',' '{print $2}' | sed -e 's|\..*||')
        DARK_SCORE=$(echo "$SCORE" | awk -F',' '{print $4}' | sed -e 's|\..*||')        
        GAME_COUNT=$((1 + $GAME_COUNT))

        #if [ "$DARK_SCORE" = "$WHITE_SCORE" ]; then
        #    TIES=$(($TIES + 1))
        #    WHITE_TIE=$(echo "$SCORE" | awk -F',' '{print $2}' | awk -F'.' '{print $2}')
        #    DARK_TIE=$(echo "$SCORE" | awk -F',' '{print $4}' | awk -F'.' '{print $2}')
        #    if [ "$WHITE_TIE" -gt "$BLACK_TIE" ]; then
        #        
        #    fi
        #fi

        if [ "$TEAM" = "$WHITE" ]; then
            GOALS_FOR=$(($GOALS_FOR + $WHITE_SCORE))
            if [ "$WHITE_SCORE" -gt "$DARK_SCORE" ]; then
                WINS=$(($WINS + 1))
            elif [ "$WHITE_SCORE" -lt "$DARK_SCORE" ]; then
                LOSSES=$(($LOSSES + 1))
            else
                TIES=$(($TIES + 1))
            fi
        else
            GOALS_AGAINST=$(($GOALS_AGAINST + $WHITE_SCORE))
            PLACING=$(grep "$WHITE" "$2" | awk -F',' '{print $1}' | sed -e "s|.*_||")
            COMP_RANK=$(($COMP_RANK + $PLACING))
        fi
        if [ "$TEAM" = "$DARK" ]; then
            GOALS_FOR=$(($GOALS_FOR + $DARK_SCORE))
            if [ "$DARK_SCORE" -gt "$WHITE_SCORE" ]; then
                WINS=$(($WINS + 1))
            elif [ "$DARK_SCORE" -lt "$WHITE_SCORE" ]; then
                LOSSES=$(($LOSSES + 1))
            else
                TIES=$(($TIES + 1))
            fi            
        else
            GOALS_AGAINST=$(($GOALS_AGAINST + $DARK_SCORE))
            PLACING=$(grep "$DARK" "$2" | awk -F',' '{print $1}' | sed -e "s|.*_||")
            COMP_RANK=$(($COMP_RANK + $PLACING))      
        fi      
    done
    PLACING=$(grep "$TEAM" "$2" | awk -F',' '{print $1}' | sed -e "s|.*_||")
    LEVEL=$(grep "$TEAM" "$2" | awk -F'_' '{print $1}')
    GOALS_FOR_PER_GAME=$(echo "scale=2; $GOALS_FOR / $GAME_COUNT" | bc)
    GOALS_AGAINST_AGAINST_PER_GAME=$(echo "scale=2; $GOALS_AGAINST / $GAME_COUNT" | bc)
    DELTA=$(echo "scale=2; $GOALS_FOR_PER_GAME - $GOALS_AGAINST_AGAINST_PER_GAME" | bc)
    COMP_RANK_COMPUTED=$(echo "scale=2; $COMP_RANK / $GAME_COUNT" | bc)    
    echo "$TEAM,$LEVEL,$PLACING,$GOALS_FOR_PER_GAME,$GOALS_AGAINST_AGAINST_PER_GAME,$DELTA,$COMP_RANK_COMPUTED,$WINS,$LOSSES,$TIES"
    
done

