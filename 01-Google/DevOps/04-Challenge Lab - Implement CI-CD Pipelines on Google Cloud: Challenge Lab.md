# Implement CI-CD Pipelines on Google Cloud: Challenge Lab

## Task 1. Prework - Set up environment, enable APIs and create clusters
```
echo -e "\n## Task 1. Prework - Set up environment, enable APIs and create clusters\n"

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=europe-west4
export ZONE=$REGION-b
gcloud config set compute/region $REGION
```
```
gcloud services enable \
container.googleapis.com \
clouddeploy.googleapis.com \
artifactregistry.googleapis.com \
cloudbuild.googleapis.com
```

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
--format="value(projectNumber)")-compute@developer.gserviceaccount.com \
--role="roles/clouddeploy.jobRunner"

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
--format="value(projectNumber)")-compute@developer.gserviceaccount.com \
--role="roles/container.developer"


gcloud artifacts repositories create cicd-challenge \
--description="Image registry for tutorial web app" \
--repository-format=docker \
--location=$REGION


gcloud container clusters create cd-staging --node-locations=$ZONE --num-nodes=1 --async
gcloud container clusters create cd-production --node-locations=$ZONE --num-nodes=1 --async
```

## Task 2. Build the images and upload to the repository
```
echo -e "\n\t## Task 2. Build the images and upload to the repository\n"

cd ~/
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
git checkout c3cae80 --quiet
cd tutorials/base

envsubst < clouddeploy-config/skaffold.yaml.template > web/skaffold.yaml
cat web/skaffold.yaml
```
```
cd web
skaffold build --interactive=false \
--default-repo $REGION-docker.pkg.dev/$PROJECT_ID/cicd-challenge \
--file-output artifacts.json
cd ..
```

## Task 3. Create the Delivery Pipeline
```
echo -e "\n\t## Task 3. Create the Delivery Pipeline"

cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
sed -i "s/targetId: staging/targetId: cd-staging/" clouddeploy-config/delivery-pipeline.yaml
sed -i "s/targetId: prod/targetId: cd-production/" clouddeploy-config/delivery-pipeline.yaml
sed -i "/targetId: test/d" clouddeploy-config/delivery-pipeline.yaml
```
```
gcloud config set deploy/region $REGION

gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml

gcloud beta deploy delivery-pipelines describe web-app
```

### Configure the deployment targets
```
echo -e "\n\t### Configure the deployment targets\n"

gcloud container clusters list --format="csv(name,status)"

while gcloud container clusters list --format="csv(name,status)" | grep -q PROVISIONING
do
    echo "Cluster still in Provisioning State"
    sleep 2
done

gcloud container clusters list --format="csv(name,status)"

echo -e "\n\t### Cluster in Running State ###\n"
```


### Create a context for each cluster
```
echo -e "\n\t### Create a context for each cluster\n"

CONTEXTS=("cd-staging" "cd-production")
for CONTEXT in ${CONTEXTS[@]}
do
    gcloud container clusters get-credentials ${CONTEXT} --region ${REGION}
    kubectl config rename-context gke_${PROJECT_ID}_${REGION}_${CONTEXT} ${CONTEXT}
done
```
### Create a namespace in each cluster
```
echo -e "\n\t### Create a namespace in each cluster\n"

for CONTEXT in ${CONTEXTS[@]}
do
    kubectl --context ${CONTEXT} apply -f kubernetes-config/web-app-namespace.yaml
done
```
### Create the delivery pipeline targets
```
echo -e "\n\t### Create the delivery pipeline targets\n"

envsubst < clouddeploy-config/target-staging.yaml.template > clouddeploy-config/target-cd-staging.yaml
envsubst < clouddeploy-config/target-prod.yaml.template > clouddeploy-config/target-cd-production.yaml
```

```
sed -i "s/staging/cd-staging/" clouddeploy-config/target-cd-staging.yaml
sed -i "s/prod/cd-production/" clouddeploy-config/target-cd-production.yaml

cat clouddeploy-config/target-cd-staging.yaml
cat clouddeploy-config/target-cd-production.yaml

for CONTEXT in ${CONTEXTS[@]}
do
    gcloud beta deploy apply --file clouddeploy-config/target-$CONTEXT.yaml
done
sleep 10 
```
#### Apply the target files to Cloud Deploy.
```
echo -e "\n\t#### Apply the target files to Cloud Deploy\n"

gcloud beta deploy targets list
```

## Task 4. Create a Release
```
echo -e "\n\t## Task 4. Create a Release\n"

gcloud beta deploy releases create web-app-001 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001



sleep 30 
```
## Task 5. Promote your application to production
```
echo -e "\n\t## Task 5. Promote your application to production\n"

gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001


gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001

sleep 20 

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001

gcloud beta deploy rollouts approve web-app-001-to-${CONTEXTS[1]}-0001 \
--delivery-pipeline web-app \
--release web-app-001

sleep 10 

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001


CONTEXTS=("cd-staging" "cd-production")

for CONTEXT in ${CONTEXTS[@]}
do
    kubectx $CONTEXT
    kubectl get all -n web-app
done

sleep 30
```

## Task 6. Make a change to the application and redeploy it
```
echo -e "\n\t## Task 6. Make a change to the application and redeploy it\n"


# edit ~/cloud-deploy-tutorials/tutorials/base/web/leeroy-app/app.go


sed -i "s/leeroooooy app\!\!/leeroooooy app v2\!\!/g" ~/cloud-deploy-tutorials/tutorials/base/web/leeroy-app/app.go

cd web
skaffold build --interactive=false \
--default-repo $REGION-docker.pkg.dev/$PROJECT_ID/cicd-challenge \
--file-output artifacts.json
cd ..



gcloud beta deploy releases create web-app-002 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-002


sleep 10 

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-002
```

## Task 7. Rollback The Change
```
echo -e "\n\t## Task 7. Rollback The Change\n"

gcloud beta deploy targets rollback ${CONTEXTS[0]} --delivery-pipeline web-app  --region=$REGION --release web-app-001
```
