

## create a new AlloyDB cluster
gcloud beta alloydb clusters create gcloud-lab-cluster \
    --password=Change3Me \
    --network=peering-network \
    --region=us-east4 \
    --project=qwiklabs-gcp-04-3980f6c64941

## create the Primary instance
gcloud beta alloydb instances create gcloud-lab-instance \
    --instance-type=PRIMARY \
    --cpu-count=2 \
    --region=us-east4  \
    --cluster=gcloud-lab-cluster \
    --project=qwiklabs-gcp-04-3980f6c64941

## list the AlloyDB clusters instances available
gcloud beta alloydb clusters list

## Get the private IP
# gcloud alloydb instances describe [$ALLOYDB_INSTANCE_NAME] --cluster [$ALLOYDB_CLUSTER_NAME] --region [$REGION] --format="get(ipAddress)"

gcloud alloydb instances describe gcloud-lab-instance \
    --cluster gcloud-lab-cluster \
    --region us-east4 \
    --format="get(ipAddress)"

export ALLOYDB=$(gcloud alloydb instances describe gcloud-lab-instance --cluster gcloud-lab-cluster --region us-east4 --format="get(ipAddress)")

echo $ALLOYDB  >> alloydbip.txt 

# PGPASSWORD='yourpassword' psql -h yourhostname -U yourusername -d yourdatabase
# or
# export PGPASSWORD='yourpassword'
# psql -h yourhostname -U yourusername -d yourdatabase 

export PGPASSWORD='Change3Me'
psql -h $ALLOYDB -U postgres


# Delete the Cluster

gcloud beta alloydb clusters delete gcloud-lab-cluster \
    --force \
    --region=us-east4 \
    --project=qwiklabs-gcp-04-3980f6c64941