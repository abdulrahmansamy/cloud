#!/bin/bash -e
# Implement DevOps Workflows in Google Cloud: Challenge Lab


Black='\033[0;30m'
Dark_Gray='\033[1;30m'
RED='\033[1;31m'
Light_Red='\033[0;31m'
Green='\033[1;32m'
Light_Green='\033[0;32m'
Yellow='\033[1;33m'
Light_Yellow='\033[0;33m'
Blue='\033[1;34m'
Light_Blue='\033[0;34m'
Purple='\033[1;35m'
Light_Purple='\033[0;35m'
Cyan='\033[1;36m'
Light_Cyan='\033[0;36m'
White='\033[1;37m'
Light_White='\033[0;37m'

NOCOLOR='\033[0m'

echo -e "$Yellow\nImplement DevOps Workflows in Google Cloud: Challenge Lab\n$NOCOLOR"

## Task 0. Initializing the Lab


echo -e "$Light_Yellow\n\tTask 0. Initializing the Lab\n$NOCOLOR"

#set +e
gcloud auth list

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

export REGION="${ZONE%-*}"

# export REGION=us-west1
# export ZONE=$REGION-c

export CLUSTER_NAME=hello-cluster
export REPO=my-repository

export PRODNS=prod
export DEVNS=dev

gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    sourcerepo.googleapis.com

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
--format="value(projectNumber)")@cloudbuild.gserviceaccount.com --role="roles/container.developer"

gcloud config set compute/region $REGION


## Task 1. Create the lab resources
echo -e "$Light_Yellow\n\tTask 1. Create the lab resources\n$NOCOLOR"

gcloud artifacts repositories create my-repository \
  --repository-format=docker \
  --location=$REGION

git config --global user.email email@email.com
git config --global user.name mail

gcloud beta container clusters create hello-cluster --zone $ZONE --release-channel regular --enable-autoscaling \
 --min-nodes 2 --max-nodes 6 --num-nodes 3 --cluster-version=1.29 --async

# gcloud container clusters create "hello-cluster" --zone $ZONE --no-enable-basic-auth --cluster-version 1.29 --release-channel "regular" --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --default-max-pods-per-node "110" --enable-autoscaling --min-nodes "2" --max-nodes "6" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-managed-prometheus --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --node-locations $ZONE --async

gcloud container clusters list --format="csv(name,status)"

SEC=0
while gcloud container clusters list --format="csv(name,status)" | grep -q PROVISIONING
do
    echo -ne "Cluster still in Provisioning State: $SEC seconds\r"
    let SEC=SEC+1
    sleep 1
done

gcloud container clusters list --format="csv(name,status)"

echo
echo -e "\n\t${Light_Green}Cluster in Running State\n$NOCOLOR"

gcloud container clusters get-credentials hello-cluster --zone $ZONE

kubectl create namespace $PRODNS
kubectl create namespace $DEVNS

## Task 2. Create a repository in Cloud Source Repositories
echo -e "$Light_Yellow\n\tTask 2. Create a repository in Cloud Source Repositories\n$NOCOLOR"

gcloud source repos create sample-app

gcloud source repos clone sample-app --project=$PROJECT_ID

gsutil cp -r gs://spls/gsp330/sample-app/* ~/sample-app

for file in ~/sample-app/cloudbuild-dev.yaml ~/sample-app/cloudbuild.yaml; do
    sed -i "s/<your-region>/${REGION}/g" "$file"
    sed -i "s/<your-zone>/${ZONE}/g" "$file"
done

cd ~/sample-app
git add --all
git commit -am "initial"
git push -u origin master
git checkout -b dev

git push -u origin dev

## Task 3. Create the Cloud Build Triggers
echo -e "$Light_Yellow\n\tTask 3. Create the Cloud Build Triggers\n$NOCOLOR"

gcloud builds triggers create cloud-source-repositories --name=sample-app-prod-deploy --repo=sample-app \
 --build-config=cloudbuild.yaml --service-account="projects/$PROJECT_ID/serviceAccounts/$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
 --branch-pattern='^master$'

gcloud beta builds triggers create cloud-source-repositories --name=sample-app-dev-deploy \
--repo=sample-app --build-config=cloudbuild-dev.yaml \
--service-account="projects/$PROJECT_ID/serviceAccounts/$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com"  --branch-pattern='^dev$'

## Task 4. Deploy the first versions of the application
echo -e "$Light_Yellow\n\tTask 4. Deploy the first versions of the application\n$NOCOLOR"

### Build the first development deployment
echo -e "$Light_Blue\n\t\t## Build the first development deployment\n$NOCOLOR"

git checkout dev
sed -i "s/<version>/v1.0/g" cloudbuild-dev.yaml
sed -i "s/<todo>/${REGION}-docker.pkg.dev\/$PROJECT_ID\/my-repository\/hello-cloudbuild-dev:v1.0/g" \
dev/deployment.yaml

git commit -am "dev v1.0"
git push -u origin dev

# Waiting for the build
for i in {1..60}; do
    echo -ne "Waiting for the build: $i\r"
    sleep 1
done
echo -ne "\nDone! \n"

# sleep 30

kubectl expose deployment development-deployment --port=8080 --target-port=8080 \
        --name=$DEVNS-deployment-service --type=LoadBalancer -n $DEVNS

echo -e "$Light_Purple\n\t\tWaiting for the External Load Balancer IP of the exposed 'development-deployment' to be ready\n$NOCOLOR"
# bash
SEC=0
while  ! [ -n "$(kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" ];
do 
  echo -ne "\t Waiting for $DEVNS-deployment-service Load Balancer IP: $SEC"
  let SEC=SEC+1
  sleep 1
done

echo -e "\t The $DEVNS-deployment-service Load Balancer IP is: $(kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# sleep 20
# kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# echo

echo  http://`kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue
echo  http://`kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red


### Build the first production deployment
echo -e "$Light_Blue\n\t\t## Build the first production deployment\n$NOCOLOR"

git checkout master

sed -i "s/<version>/v1.0/g" cloudbuild.yaml
sed -i "s/<todo>/${REGION}-docker.pkg.dev\/$PROJECT_ID\/my-repository\/hello-cloudbuild:v1.0/g" \
prod/deployment.yaml

git commit -am "prod v1.0"
git push -u origin master

# Waiting for the build
for i in {1..60}; do
    echo -ne "Waiting for the build: $i\r"
    sleep 1
done
echo -ne "\nDone! \n"

# sleep 30

kubectl expose deployment production-deployment --port=8080 --target-port=8080 \
        --name=$PRODNS-deployment-service --type=LoadBalancer -n $PRODNS

#### Function to check if the External Load Balancer IP of the exposed `production-deployment` is ready or not
echo -e "$Light_Purple\n\t\tWaiting for the External Load Balancer IP of the exposed 'production-deployment' to be ready\n$NOCOLOR"
# bash
SEC=0
while  ! [ -n "$(kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" ];
do 
  echo -ne "\t Waiting for $PRODNS-deployment-service Load Balancer IP: $SEC"
  let SEC=SEC+1
  sleep 1
done

echo -e "\t The $PRODNS-deployment-service Load Balancer IP is: $(kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"



# VVV=`kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip1}'`
# if [ -z "$(kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" ]; then
#   echo "The variable is empty"
# else
#   echo "the ip is $vvv"
# fi




# sleep 40
# kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# echo $?

echo
echo  http://`kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue
echo  http://`kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red
echo
# curl -s  http://`kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue


## Task 5. Deploy the second versions of the application
echo -e "$Light_Yellow\n\tTask 5. Deploy the second versions of the application\n$NOCOLOR"
### Build the second development deployment
echo -e "$Light_Blue\n\t\t## Build the second development deployment\n$NOCOLOR"

git checkout dev

sed -i "s/v1.0/v2.0/g" cloudbuild-dev.yaml
sed -i "s/v1.0/v2.0/g" dev/deployment.yaml

# edit main.go

sed -i '/http.HandleFunc("\/blue", blueHandler)/a\ \thttp.HandleFunc("/red", redHandler)' main.go

cat << EOF >> main.go

func redHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}
EOF


git commit -am "dev v2.0"
git push -u origin dev

# Waiting for the build
for i in {1..30}; do
    echo -ne "Waiting for the build: $i\r"
    sleep 1
done
echo -ne "\nDone! \n"

kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

echo
echo  http://`kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue
echo  http://`kubectl get svc -n $DEVNS $DEVNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red
echo

### Build the second production deployment
echo -e "$Light_Blue\n\t\t## Build the second production deployment\n$NOCOLOR"

git checkout master

sed -i "s/v1.0/v2.0/g" cloudbuild.yaml
sed -i "s/v1.0/v2.0/g" prod/deployment.yaml

# edit main.go


sed -i '/http.HandleFunc("\/blue", blueHandler)/a\ \thttp.HandleFunc("/red", redHandler)' main.go

cat << EOF >> main.go

func redHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}
EOF


git commit -am "prod v2.0"
git push -u origin master

# Waiting for the build
for i in {1..30}; do
    echo -ne "Waiting for the build: $i\r"
    sleep 1
done
echo -ne "\nDone! \n"

kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

echo
echo  http://`kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue

echo  http://`kubectl get svc -n $PRODNS $PRODNS-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red


## Task 6. Roll back the production deployment
echo -e "$Light_Yellow\n\tTask 6. Roll back the production deployment\n$NOCOLOR"

## Check the containers version before the roll back
echo -e "$Light_Blue\n\t\t## Check the containers version before the roll back\n$NOCOLOR"

kubectl -n $PRODNS get pods -o jsonpath \
  --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

## Perform the roll back
echo -e "$Light_Blue\n\t\t## Perform the roll back\n$NOCOLOR"

kubectl rollout undo deployment production-deployment  -n $PRODNS

# Waiting for the build
for i in {1..10}; do
    echo -ne "Waiting for the build: $i\r"
    sleep 1
done
echo -ne "\nDone! \n"

## Check the containers version after the roll back
echo -e "$Light_Blue\n\t\t## Check the containers version after the roll back\n$NOCOLOR"
kubectl -n $PRODNS get pods -o jsonpath \
  --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
