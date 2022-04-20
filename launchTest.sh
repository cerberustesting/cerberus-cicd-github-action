#!/bin/bash

###Get CampaignName and Cerberus Host
while getopts a:h:c:k: flag
do
    case "${flag}" in
        a) AUTHOR=${OPTARG};;
        h) HOST=${OPTARG};;
        c) CAMPAIGN=${OPTARG};;
        k) APIKEY=${OPTARG};;
    esac
done
echo "Author: $AUTHOR";
echo "Cerberus Host: $HOST";
echo "Campaign Name: $CAMPAIGN";

###Generate Tag using Campaign Name, Commiter and UnixTimestamp
tag=$CAMPAIGN.$AUTHOR.$(date +%s)

###Run Campaign
curl -s --request POST --url "$HOST/AddToExecutionQueueV003" -d campaign=$CAMPAIGN -d tag=$tag -H "apikey:$APIKEY"
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
