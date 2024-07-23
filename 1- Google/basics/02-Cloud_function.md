

```bash
echo $GOOGLE_CLOUD_PROJECT
```

Create a Cloud Storage bucket

```bash
gsutil mb -p [PROJECT_ID] gs://[BUCKET_NAME]
```

```bash
gsutil mb -p $GOOGLE_CLOUD_PROJECT gs://$GOOGLE_CLOUD_PROJECT
```

## Deploy your function

### Enable the Cloud Functions API

```sh
gcloud services enable cloudfunctions.googleapis.com
```

to disable Cloud Function API
```sh
gcloud services disable cloudfunctions.googleapis.com
```

### Add the artifactregistry.reader permission for your appspot service account.
  
```sh
gcloud projects add-iam-policy-binding [PROJECT_ID] \
--member="serviceAccount:[PROJECT_ID]@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"
```

```bash
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT  \
--member="serviceAccount:$GOOGLE_CLOUD_PROJECT@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"
```

### Deploy the function to a pub/sub topic named hello_world
```bash
gcloud functions deploy helloWorld \
  --stage-bucket [BUCKET_NAME] \
  --trigger-topic hello_world \
  --runtime nodejs20
  ```


```bash
gcloud functions deploy helloWorld \
  --stage-bucket $GOOGLE_CLOUD_PROJECT \
  --trigger-topic hello_world \
  --runtime nodejs20
  ```

### Verify the status of the function
```bash
gcloud functions describe helloWorld
```

```
DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'
```

```
gcloud functions logs read helloWorld
```

