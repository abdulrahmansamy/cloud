### Task 1. Create the lab resources
```
gcloud auth list

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

export REGION=us-west1
export ZONE=us-west1-c
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


gcloud beta container clusters create hello-cluster --zone $ZONE --release-channel regular --enable-autoscaling  --min-nodes 2 --max-nodes 6 --num-nodes 3 --cluster-version=1.29

gcloud container clusters get-credentials hello-cluster --zone $ZONE


kubectl create namespace prod

kubectl create namespace dev
```

### Task 2. Create a repository in Cloud Source Repositories
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
### Task 3. Create the Cloud Build Triggers

```
gcloud builds triggers create cloud-source-repositories --name=sample-app-prod-deploy --repo=sample-app --branch-pattern='^master$' --build-config=cloudbuild.yaml --service-account=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com




gcloud beta builds triggers create cloud-source-repositories --name=sample-app-dev-deploy --repo=sample-app --branch-pattern='^dev$' --build-config=cloudbuild-dev.yaml --service-account=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com
```

### Task 4. Deploy the first versions of the application

```
git checkout dev
sed -i "s/<version>/v1.0/g" cloudbuild-dev.yaml
sed -i "s/<todo>/us-west1-docker.pkg.dev\/$PROJECT_ID\/my-repository\/hello-cloudbuild-dev:v1.0/g" dev/deployment.yaml

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
git checkout master

sed -i "s/<version>/v1.0/g" cloudbuild.yaml
sed -i "s/<todo>/us-west1-docker.pkg.dev\/$PROJECT_ID\/my-repository\/hello-cloudbuild:v1.0/g" prod/deployment.yaml

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

### Task 5. Deploy the second versions of the application

```
git checkout dev

sed -i "s/v1.0/v2.0/g" cloudbuild-dev.yaml
sed -i "s/v1.0/v2.0/g" dev/deployment.yaml
edit main.go
```


```

git commit -am "dev v2.0"
git push -u origin dev
```

```
git checkout master

sed -i "s/v1.0/v2.0/g" cloudbuild.yaml
sed -i "s/v1.0/v2.0/g" prod/deployment.yaml
edit main.go
```
```
git commit -am "prod v2.0"
git push -u origin master
```

### Task 6. Roll back the production deployment
```
kubectl rollout undo deployment production-deployment  -n prod
```

```
kubectl -n prod get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
```