#!/bin/bash

function usage(){
    echo "USAGE:"
    echo "$0 <scores.csv> <placings.csv>"
    echo ""
    echo "Sample format"
    echo "scores.csv"
    echo "NEWPORT BEACH BLUE,6,DIABLO A,2"
    echo "SOCAL,5,SOUTH COAST RED,6"
    echo "PUNAHOU,7,CLOVIS,13"
    echo "LAMORINDA B,5.2,ARROYO GRANDE,5.1"
    echo ""
    echo "placings.csv"
    echo "P_1,W192-NEWPORT BEACH BLUE"
    echo "P_2,L192-PATRIOT NAVY"
    echo "P_3,W191-DIABLO A"
    echo "P_4,L191-STANFORD A"
    echo "[...]"
    echo "G_47,PRAETORIAN"
    echo "G_48,PUNAHOU"
}


if [ -z $2 ]; then
    usage
    exit 1;
fi
echo "TEAM,LEVEL,PLACING,GOALS FOR PER GAME,GOALS AGAINST PER GAME,POINT DELTA,SCHEDULE STRENGTH,WINS,LOSSES,TIES,TIE WINS,TIE LOSSES"

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
        WHITE_TIE=$(echo "$SCORE" | awk -F',' '{print $2}' | awk -F'.' '{print $2}') 
        DARK_TIE=$(echo "$SCORE" | awk -F',' '{print $4}' | awk -F'.' '{print $2}')

        if [ "$TEAM" = "$WHITE" ]; then
            GOALS_FOR=$(($GOALS_FOR + $WHITE_SCORE))
            if [ "$WHITE_SCORE" -gt "$DARK_SCORE" ]; then
                WINS=$(($WINS + 1))
            elif [ "$WHITE_SCORE" -lt "$DARK_SCORE" ]; then
                LOSSES=$(($LOSSES + 1))
            else
                TIES=$(($TIES + 1))
                if [ "$WHITE_TIE" -gt "$DARK_TIE" ]; then
                    TIE_WINS=$((TIE_WINS + 1))
                else
                    TIE_LOSSES=$((TIE_LOSSES + 1))  
                fi
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
                if [ "$DARK_TIE" -gt "$WHITE_TIE" ]; then
                    TIE_WINS=$((TIE_WINS + 1))
                else
                    TIE_LOSSES=$((TIE_LOSSES + 1))  
                fi                
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
    echo "$TEAM,$LEVEL,$PLACING,$GOALS_FOR_PER_GAME,$GOALS_AGAINST_AGAINST_PER_GAME,$DELTA,$COMP_RANK_COMPUTED,$WINS,$LOSSES,$TIES,$TIE_WINS,$TIE_LOSSES"
    
done

