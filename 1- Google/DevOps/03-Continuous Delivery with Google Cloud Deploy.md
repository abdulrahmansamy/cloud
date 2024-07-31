# Continuous Delivery with Google Cloud Deploy

touch script.sh && chmod +x $_ && ll $_ && edit $_

sh $_



#!/bin/bash -e

gcloud auth list

# Task 1. Set variables

echo -e "\n# Task 1. Set variables\n"

export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-west1
export ZONE=$REGION-c
gcloud config set compute/region $REGION



# Task 2. Create three GKE clusters

echo -e "\n# Task 2. Create three GKE clusters\n"

gcloud services enable \
container.googleapis.com \
clouddeploy.googleapis.com

gcloud container clusters create test --node-locations=$ZONE --num-nodes=1  --async
gcloud container clusters create staging --node-locations=$ZONE --num-nodes=1  --async
gcloud container clusters create prod --node-locations=$ZONE --num-nodes=1  --async

gcloud container clusters list --format="csv(name,status)"


# Task 3. Prepare the web application container image

echo -e "\n# Task 3. Prepare the web application container image\n"

gcloud services enable artifactregistry.googleapis.com

gcloud artifacts repositories create web-app \
--description="Image registry for tutorial web app" \
--repository-format=docker \
--location=$REGION

# Task 4. Build and deploy the container images to the Artifact Registry

echo -e "\n# Task 4. Build and deploy the container images to the Artifact Registry\n"

cd ~/
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
git checkout c3cae80 --quiet
cd tutorials/base

envsubst < clouddeploy-config/skaffold.yaml.template > web/skaffold.yaml
cat web/skaffold.yaml

gcloud services enable cloudbuild.googleapis.com

cd web
skaffold build --interactive=false \
--default-repo $REGION-docker.pkg.dev/$PROJECT_ID/web-app \
--file-output artifacts.json
cd ..

gcloud artifacts docker images list \
$REGION-docker.pkg.dev/$PROJECT_ID/web-app \
--include-tags \
--format yaml

cat web/artifacts.json | jq



# Task 5. Create the delivery pipeline

echo -e "\n# Task 5. Create the delivery pipeline\n"

gcloud services enable clouddeploy.googleapis.com

gcloud config set deploy/region $REGION
cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml

gcloud beta deploy delivery-pipelines describe web-app



# Task 6. Configure the deployment targets

echo -e "\n# Task 6. Configure the deployment targets\n"

gcloud container clusters list --format="csv(name,status)"

while gcloud container clusters list --format="csv(name,status)" | grep -q PROVISIONING
do
    echo "Cluster still in Provisioning State"
    sleep 2
done

gcloud container clusters list --format="csv(name,status)"

echo "### Cluster in Running State ###"



CONTEXTS=("test" "staging" "prod")
for CONTEXT in ${CONTEXTS[@]}
do
    gcloud container clusters get-credentials ${CONTEXT} --region ${REGION}
    kubectl config rename-context gke_${PROJECT_ID}_${REGION}_${CONTEXT} ${CONTEXT}
done


for CONTEXT in ${CONTEXTS[@]}
do
    kubectl --context ${CONTEXT} apply -f kubernetes-config/web-app-namespace.yaml
done

for CONTEXT in ${CONTEXTS[@]}
do
    envsubst < clouddeploy-config/target-$CONTEXT.yaml.template > clouddeploy-config/target-$CONTEXT.yaml
    gcloud beta deploy apply --file clouddeploy-config/target-$CONTEXT.yaml
done

cat clouddeploy-config/target-test.yaml

cat clouddeploy-config/target-prod.yaml

echo 
echo 

sleep 10 

gcloud beta deploy targets list


# Task 7. Create a release

echo -e "\n# Task 7. Create a release\n"


sleep 10 


gcloud beta deploy releases create web-app-001 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001


kubectx test
kubectl get all -n web-app

# Task 8. Promote the application to staging

echo -e "\n# Task 8. Promote the application to staging\n"

sleep 10 


gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001


gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001


# Task 9. Promote the application to prod

echo -e "\n# Task 9. Promote the application to prod\n"

sleep 30 


gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001

gcloud beta deploy rollouts approve web-app-001-to-prod-0001 \
--delivery-pipeline web-app \
--release web-app-001

gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001

kubectx prod
kubectl get all -n web-app














