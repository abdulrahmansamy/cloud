gcloud alloydb instances create lab-instance-rp1 \
    --cluster=lab-cluster \
    --region=us-east4 \
    --project=qwiklabs-gcp-01-13cee63058d4 \
    --instance-type=READ_POOL \
    --cpu-count=2 \
    --read-pool-node-count=2

gcloud alloydb backups create lab-backup \
    --cluster=lab-cluster \
    --region=us-east4 \
    --project=qwiklabs-gcp-01-13cee63058d4 