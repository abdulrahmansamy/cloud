PROJECT_ID=qwiklabs-gcp-00-b6b2c2834513
REGION=us-west1
ZONE=us-west1-a

gcloud alloydb clusters create lab-cluster \
    --password=Change3Me \
    --network=peering-network \
    --region=$REGION \
    --project=$PROJECT_ID

gcloud alloydb instances create lab-instance \
    --instance-type=PRIMARY \
    --cpu-count=2 \
    --region=$REGION  \
    --cluster=lab-cluster  \
    --project=$PROJECT_ID

gcloud alloydb instances create lab-instance-rp1 \
    --cluster=lab-cluster \
    --region=$REGION \
    --project=$PROJECT_ID \
    --instance-type=READ_POOL \
    --cpu-count=2 \
    --read-pool-node-count=2

gcloud alloydb backups create lab-backup \
    --cluster=lab-cluster \
    --region=$REGION \
    --project=$PROJECT_ID


gcloud alloydb clusters list



################################
##### Deleting the Cluster #####
################################

## Delete Read Pool Instance
gcloud alloydb instances delete lab-instance-rp1 \
    --async \
    --cluster=lab-cluster \
    --region=$REGION \
    --project=$PROJECT_ID

## Delete Primary Instance
gcloud alloydb instances delete lab-instance \
    --async \
    --cluster=lab-cluster \
    --region=$REGION \
    --project=$PROJECT_ID

## Delete Cluster
gcloud alloydb clusters delete lab-cluster \
    --force \
    --region=$REGION \
    --project=$PROJECT_ID

## Delete Backup
gcloud alloydb backups delete lab-backup \
    --region=$REGION \
    --project=$PROJECT_ID
