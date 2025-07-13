#!/bin/bash

###Get CampaignName and Cerberus Host
while getopts a:h:c:k:t:u:d:C:E:R:T: flag
do
    case "${flag}" in
        a) AUTHOR=${OPTARG};;
        h) HOST=${OPTARG};;
        c) CAMPAIGN=${OPTARG};;
        k) APIKEY=${OPTARG};;
        t) TIMEOUT=${OPTARG};;
        u) ITDUR=${OPTARG};;
        d) DEBUG=" -v";;
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
#echo "Debug: $DEBUG";

###If Iteration Duration not provided, default to 3
if [[ "$ITDUR" == "" ]]; 
then
    ITDUR=3;
fi

###If Timeout Iteration nb not provided, default to 300
if [[ "$TIMEOUT" != "" ]]; 
then
    echo "Timeout: $TIMEOUT iterations of $ITDUR sec";
else
    TIMEOUT=500;
    echo "Timeout (default): $TIMEOUT iterations of $ITDUR sec";
fi

###Control host value
if [[ "$HOST" == "" ]]; 
then
    echo "HOST not defined!!";
    exit 1;
fi

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
    tag=$TAG
else
    tag=$CAMPAIGN.$AUTHOR.$(date +%y%m%d-%H%M%S)
fi
EXTRA_ARGS+=(-d "tag=$tag")

###Run Campaign
echo "Trigger Campaign '$CAMPAIGN' to '$HOST/AddToExecutionQueueV003' with tag '$TAG'"
callTrigger=$(curl -s $DEBUG --request POST --url "$HOST/AddToExecutionQueueV003" -d campaign=$CAMPAIGN -d outputformat=json "${EXTRA_ARGS[@]}" -H "apikey:$APIKEY")
callTriggerRC=$(echo $callTrigger | jq -r '.messageType')
callTriggerMess=$(echo $callTrigger | jq -r '.message')

if [[ "$callTriggerRC" != "OK" ]]; then
    echo "Could not trigger the campaign!!"
    echo $callTriggerMess
    exit 1
else
    echo $callTriggerMess
fi


#echo $callTrigger

###Loop on resultCI Until end of campaign
num=1
while [ $num -le $TIMEOUT ]
do
    sleep $ITDUR
## Get the tag result.
    resultFull=$(curl -s $DEBUG --request POST --url "$HOST/ResultCIV004" -d tag=$tag -H "apikey:$APIKEY")
## Parsing call result
    result=$(echo $resultFull | jq -r '.result')
    resultMess=$(echo $resultFull | jq -r '.message')
    resultTot=$(echo $resultFull | jq -r '.TOTAL_nbOfExecution')
    resultQU=$(echo $resultFull | jq -r '.status_QU_nbOfExecution')
    resultPE=$(echo $resultFull | jq -r '.status_PE_nbOfExecution')
    resultOK=$(echo $resultFull | jq -r '.status_OK_nbOfExecution')
    resultKO=$(echo $resultFull | jq -r '.status_KO_nbOfExecution')
    resultFA=$(echo $resultFull | jq -r '.status_FA_nbOfExecution')
    resultCIR=$(echo $resultFull | jq -r '.CI_finalResult')
    resultCIT=$(echo $resultFull | jq -r '.CI_finalResultThreshold')
    echo $(date +%y-%m-%d" "%H:%M:%S)" Check Campaign result ($num/$TIMEOUT) | QU:"$resultQU" PE:"$resultPE" | OK:"$resultOK" KO:"$resultKO" FA:"$resultFA 
## Exit if result is no longuer pending
    if [[ "$result" != "PE" ]]; then
        break
    fi
    ((num=num+1))
#    echo "Campaign still running... Let's try again."
done

## Timeout reached!!!
if [[ $num -ge $TIMEOUT ]]; then
    echo "Maximum iteration checks reached!!!"
    exit 1
fi

## Result fail!!!
if [[ "$result" != "OK" ]]; then
    echo "Campaign Failed. CIScore $resultCIR is above threshold $resultCIT!!!"
    exit 1
fi

## Result OK
echo "Campaign Successful. Congratulation !!!"
