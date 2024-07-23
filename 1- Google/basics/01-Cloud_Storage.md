
```
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-c
```

Create a bucket
```bash
gsutil mb gs://<YOUR-BUCKET-NAME>
```

Upload an object to the bucket
```bash
gsutil cp ada.jpg gs://YOUR-BUCKET-NAME
```

Download an object from your bucket
```bash
gsutil cp -r gs://YOUR-BUCKET-NAME/ada.jpg .
```

Copy an object to a folder in the bucket
```bash
gsutil cp gs://YOUR-BUCKET-NAME/ada.jpg gs://YOUR-BUCKET-NAME/image-folder/  #that will create image-folder
```

List contents of a bucket or folder
```bash
gsutil ls gs://YOUR-BUCKET-NAME
```


List details for an object
```bash
gsutil ls -l gs://YOUR-BUCKET-NAME/ada.jpg
```

Grant all users read permission for the object stored in your bucket
```bash
gsutil acl ch -u AllUsers:R gs://YOUR-BUCKET-NAME/ada.jpg
```




