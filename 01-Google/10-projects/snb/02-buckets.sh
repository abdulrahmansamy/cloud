gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-c

gcloud projects add-iam-policy-binding $PROJECT_ID gs://oracle-linux-9-4 --member=serviceAccount:service-773335379931@gcp-sa-vmmigration.iam.gserviceaccount.com --role=roles/storage.objectViewer


gcloud projects add-iam-policy-binding $PROJECT_ID  --member=serviceAccount:service-773335379931@gcp-sa-vmmigration.iam.gserviceaccount.com --role=roles/storage.objectViewer


oracle-linux-9-4

oracle-linux-9-4

https://storage.cloud.google.com/oracle-linux-9-4/OL9U4_x86_64-kvm-b234.qcow2


generic::permission_denied: Permission "storage.objects.get" denied on "gs://oracle-linux-9-4/OL9U4_x86_64-kvm-b234.qcow2": Please make sure the service account "service-773335379931@gcp-sa-vmmigration.iam.gserviceaccount.com" is granted with the Storage Object Viewer role. This can be done with the following command: gcloud projects add-iam-policy-binding gs://oracle-linux-9-4 --member=serviceAccount:service-773335379931@gcp-sa-vmmigration.iam.gserviceaccount.com --role=roles/storage.objectViewer