PROJECT_ID=qwiklabs-gcp-01-196f0b02b8e1
REGION=us-west1

gcloud beta alloydb clusters create SAMPLE-CLUSTER-ID \
    --password=Change3Me \
    --network=peering-network \
    --region=$REGION \
    --project=$PROJECT_ID

gcloud alloydb instances create lab-instance-rp1 \
    --cluster=lab-cluster \
    --region=$REGION \
    --project=$PROJECT_ID
    --instance-type=READ_POOL \
    --cpu-count=2 \
    --read-pool-node-count=2

gcloud alloydb backups create lab-backup \
    --cluster=lab-cluster \
    --region=$REGION \
    --project=$PROJECT_ID