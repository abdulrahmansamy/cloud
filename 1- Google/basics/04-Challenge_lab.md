

```
BUCKET_NAME=qwiklabs-gcp-04-c136a862ba53-bucket
REGION=us-central1
ZONE=$REGION-c
echo $ZONE

TOPIC=topic-memories-567
CLOUD_FUNCTION=memories-thumbnail-generator
```

```
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
```

```
gsutil mb -l $REGION gs://$BUCKET_NAME
```

```
gcloud pubsub topics create $TOPIC 
gcloud pubsub topics list
```

```
mkdir memories && cd memories
touch index.js package.json
```

```
cat << 'EOF' >> index.js
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('memories-thumbnail-creator', cloudEvent => {
  const event = cloudEvent.data;

  console.log(`Event: ${event}`);
  console.log(`Hello ${event.bucket}`);

  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "topic-memories-457";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });
          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
});

EOF
```

```
cat << 'EOF' >> package.json
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
    "@google-cloud/pubsub": "^2.0.0",
    "@google-cloud/storage": "^5.0.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}
EOF
```


```
gcloud services disable cloudfunctions.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable eventarc.googleapis.com

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT  \
--member="serviceAccount:$GOOGLE_CLOUD_PROJECT@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"



gcloud functions deploy $CLOUD_FUNCTION \
  --region $REGION --gen2 \
  --stage-bucket $BUCKET_NAME \
  --trigger-bucket $BUCKET_NAME \
  --runtime nodejs20
```

```
gcloud functions describe $CLOUD_FUNCTION
```

```
gcloud functions logs read $CLOUD_FUNCTION
```


```
curl -sLO https://storage.googleapis.com/cloud-training/gsp315/map.jpg

curl -sLo ada.jpg https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg
```

```
gsutil cp map.jpg gs://$BUCKET_NAME
```

```
gsutil cp ada.jpg gs://$BUCKET_NAME
```
