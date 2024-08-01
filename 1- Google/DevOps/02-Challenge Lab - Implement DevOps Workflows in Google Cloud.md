# Implement DevOps Workflows in Google Cloud: Challenge Lab
## Task 1. Create the lab resources
```
gcloud auth list

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

export REGION=us-east1
export ZONE=$REGION-c
```

```
gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    sourcerepo.googleapis.com

```



```
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
--format="value(projectNumber)")@cloudbuild.gserviceaccount.com --role="roles/container.developer"

gcloud config set compute/region $REGION
```

```
gcloud artifacts repositories create my-repository \
  --repository-format=docker \
  --location=$REGION

git config --global user.email email@email.com
git config --global user.name mail
```

```
gcloud beta container clusters create hello-cluster --zone $ZONE --release-channel regular --enable-autoscaling \
 --min-nodes 2 --max-nodes 6 --num-nodes 3 --cluster-version=1.29 --async
```
```
gcloud container clusters create "hello-cluster" --zone $ZONE --no-enable-basic-auth --cluster-version 1.29 --release-channel "regular" --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --default-max-pods-per-node "110" --enable-autoscaling --min-nodes "2" --max-nodes "6" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-managed-prometheus --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --node-locations $ZONE --async
```


```
gcloud container clusters list --format="csv(name,status)"

while gcloud container clusters list --format="csv(name,status)" | grep -q PROVISIONING
do
    echo "Cluster still in Provisioning State"
    sleep 2
done

gcloud container clusters list --format="csv(name,status)"

echo -e "\n\t### Cluster in Running State ###\n"


gcloud container clusters get-credentials hello-cluster --zone $ZONE


kubectl create namespace prod
kubectl create namespace dev
```

## Task 2. Create a repository in Cloud Source Repositories
```
gcloud source repos create sample-app

gcloud source repos clone sample-app --project=$PROJECT_ID
```

```

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

```
## Task 3. Create the Cloud Build Triggers

```
gcloud builds triggers create cloud-source-repositories --name=sample-app-prod-deploy --repo=sample-app \
 --build-config=cloudbuild.yaml --service-account=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com \
 --branch-pattern='^master$'




gcloud beta builds triggers create cloud-source-repositories --name=sample-app-dev-deploy \
--repo=sample-app --build-config=cloudbuild-dev.yaml \
--service-account=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com  --branch-pattern='^dev$'
```

## Task 4. Deploy the first versions of the application
### Build the first development deployment
```
git checkout dev
sed -i "s/<version>/v1.0/g" cloudbuild-dev.yaml
sed -i "s/<todo>/${REGION}-docker.pkg.dev\/$PROJECT_ID\/my-repository\/hello-cloudbuild-dev:v1.0/g" \
dev/deployment.yaml

git commit -am "dev v1.0"
git push -u origin dev
```

```
sleep 60
```

```
kubectl expose deployment development-deployment --port=8080 --target-port=8080 \
        --name=development-deployment-service --type=LoadBalancer -n dev
```

```
kubectl get svc -n dev development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'


echo  http://`kubectl get svc -n dev development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue

echo  http://`kubectl get svc -n dev development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red
```

### Build the first production deployment

```
git checkout master

sed -i "s/<version>/v1.0/g" cloudbuild.yaml
sed -i "s/<todo>/${REGION}-docker.pkg.dev\/$PROJECT_ID\/my-repository\/hello-cloudbuild:v1.0/g" \
prod/deployment.yaml

git commit -am "prod v1.0"
git push -u origin master
```

```
sleep 60
```

```
kubectl expose deployment production-deployment --port=8080 --target-port=8080 \
        --name=production-deployment-service --type=LoadBalancer -n prod
```

```
kubectl get svc -n prod production-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

echo
echo  http://`kubectl get svc -n prod production-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue

echo  http://`kubectl get svc -n prod production-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red

curl -s  http://`kubectl get svc -n prod production-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue
```

## Task 5. Deploy the second versions of the application
### Build the second development deployment
```
git checkout dev

sed -i "s/v1.0/v2.0/g" cloudbuild-dev.yaml
sed -i "s/v1.0/v2.0/g" dev/deployment.yaml

# edit main.go
```
```
sed -i '/http.HandleFunc("\/blue", blueHandler)/a\ \thttp.HandleFunc("/red", redHandler)' main.go

cat << EOF >> main.go

func redHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}
EOF
```
```
git commit -am "dev v2.0"
git push -u origin dev
```

```
kubectl get svc -n dev development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'


echo  http://`kubectl get svc -n dev development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue

echo  http://`kubectl get svc -n dev development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red
```

### Build the second production deployment
```
git checkout master

sed -i "s/v1.0/v2.0/g" cloudbuild.yaml
sed -i "s/v1.0/v2.0/g" prod/deployment.yaml

# edit main.go
```
```
sed -i '/http.HandleFunc("\/blue", blueHandler)/a\ \thttp.HandleFunc("/red", redHandler)' main.go

cat << EOF >> main.go

func redHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}
EOF
```
```
git commit -am "prod v2.0"
git push -u origin master
```

```
kubectl get svc -n prod development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

echo  http://`kubectl get svc -n prod development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/blue

echo  http://`kubectl get svc -n prod development-deployment-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`:8080/red
```

## Task 6. Roll back the production deployment

Check the containers version before the roll back
```
kubectl -n prod get pods -o jsonpath \
  --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
```
Perform the roll back
```
kubectl rollout undo deployment production-deployment  -n prod
```
Check the containers version after the roll back
```
kubectl -n prod get pods -o jsonpath \
  --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
```