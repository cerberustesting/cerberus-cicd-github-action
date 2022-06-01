#!/bin/bash

###Get CampaignName and Cerberus Host
while getopts a:h:c:k:C:E:R:T: flag
do
    case "${flag}" in
        a) AUTHOR=${OPTARG};;
        h) HOST=${OPTARG};;
        c) CAMPAIGN=${OPTARG};;
        k) APIKEY=${OPTARG};;
        C) set -f
           IFS=,
           COUNTRY=($OPTARG);;
        E) set -f
           IFS=,
           ENVIRONMENT=($OPTARG);;
        R) set -f
           IFS=,
           ROBOT=($OPTARG);;
        T) TAG=${OPTARG};;
    esac
done

EXTRA_ARGS=()
echo "Author: $AUTHOR";
echo "Cerberus Host: $HOST";
echo "Campaign Name: $CAMPAIGN";

if [[ "$COUNTRY" != "" ]]; then
    echo "Override Country: ${COUNTRY[@]}";
    for i in "${COUNTRY[@]}"; do
      EXTRA_ARGS+=(-d "country=${i}")
    done
fi

if [[ "$ENVIRONMENT" != "" ]]; then
    echo "Override Environment: ${ENVIRONMENT[@]}";
    for i in "${ENVIRONMENT[@]}"; do
      EXTRA_ARGS+=(-d "environment=${i}")
    done
fi
if [[ "$ROBOT" != "" ]]; then
    echo "Override Robot: ${ROBOT[@]}";
    for i in "${ROBOT[@]}"; do
      EXTRA_ARGS+=(-d "robot=${i}")
    done
fi

###If tag not provided, generate using Campaign Name, Commiter and UnixTimestamp
if [[ "$TAG" != "" ]]; 
then
    echo "Override Tag: $TAG";
    EXTRA_ARGS+=(-d "tag=$TAG")
else
    tag=$CAMPAIGN.$AUTHOR.$(date +%s)
    EXTRA_ARGS+=(-d "tag=$tag")
fi


###Run Campaign
curl -s --request POST --url "$HOST/AddToExecutionQueueV003" -d campaign=$CAMPAIGN "${EXTRA_ARGS[@]}" -H "apikey:$APIKEY"
echo

###Loop on resultCI Until end of campaign
num=1
while [ $num -lt 300 ]
do
    result=$(curl -s --request POST --url "$HOST/ResultCIV004" -d tag=$tag -H "apikey:$APIKEY"| jq -r '.result')
    echo "Check on Campaign ($num/300) with result : " $result
    if [[ "$result" != "PE" ]]; then
        break
    fi
    sleep 3
    ((num=num+1))
#    echo "Campaign still running... Let's try again."
done

if [[ "$result" != "OK" ]]; then
    echo "Campaign Failed. CIScore Higher than threshold !!!"
    exit 1
fi
echo "Campaign Succes. Congratulation !!!"
