#!/bin/bash
# Roll back script

ZONE=us-central1-a
REGION="${ZONE%-*}"

gcloud container clusters delete hello-cluster  --zone $ZONE --async

gcloud container clusters list --format="csv(name,status)"

SEC=0
while gcloud container clusters list --format="csv(name,status)" | grep -q STOPPING
do
    # Calculate elapsed time
    minutes=$((SEC / 60))
    seconds=$((SEC % 60))

    # echo -ne "Cluster still in Stopping State: $SEC seconds\r"
    printf "\rCluster still in Stopping State - Elapsed time: %02d minutes and %02d seconds" $minutes $seconds
    let SEC=SEC+2
    sleep 2 
done

echo
gcloud container clusters list --format="csv(name,status)"


gcloud artifacts repositories delete my-repository  --location=$REGION 


gcloud source repos delete sample-app

rm -fr ~/sample-app

gcloud builds triggers delete sample-app-prod-deploy

gcloud builds triggers delete sample-app-dev-deploy