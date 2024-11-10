# Anthos installation

## bootstrap machine preparation:

### Install `gcloud CLI`

```
mkdir ~/gcloud-cli
cd ~/gcloud-cli
```
```
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz

tar -xf google-cloud-cli-linux-x86_64.tar.gz

./google-cloud-sdk/install.sh
```

```
gcloud config get-value account
gcloud auth login
```

```
gcloud components list
gcloud components update
#gcloud components install kubectl
#gcloud components install anthos-auth
```

```
gcloud projects create anthos-demo-project-0001 --name "Anthos Demo Project"
```

```
gcloud projects list
gcloud config set project anthos-demo-project-0001
gcloud config get-value project
```
### Set variables
```
PROJECT_ID=anthos-demo-project-0001
SERVICE_ACCOUNT_EMAIL=component-access-sa@$PROJECT_ID.iam.gserviceaccount.com
ACCOUNT=abdu.samy@gmail.com
GOOGLE_ACCOUNT_EMAIL=abdu.samy@gmail.com
REGION="us-central1"
```
### Create Service Accounts
#### Component access service account
```
gcloud iam service-accounts create component-access-sa \
    --display-name "Component Access Service Account" \
    --project $PROJECT_ID
```
```
gcloud iam service-accounts keys create component-access-key.json  --iam-account component-access-sa@$PROJECT_ID.iam.gserviceaccount.com
```
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/serviceusage.serviceUsageViewer"
```
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/iam.roleViewer"
```
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/iam.serviceAccountViewer"
```
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/compute.viewer"
```
#### Connect-register service account
```
gcloud iam service-accounts create connect-register-sa \
    --project $PROJECT_ID
```
```
gcloud iam service-accounts keys create connect-register-key.json \
   --iam-account connect-register-sa@$PROJECT_ID.iam.gserviceaccount.com
```
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/gkehub.editor"
```
#### Logging-monitoring service account
```
gcloud iam service-accounts create logging-monitoring-sa \
    --project=$PROJECT_ID
```
```
gcloud iam service-accounts keys create logging-monitoring-key.json \
    --iam-account $SERVICE_ACCOUNT_EMAIL
```

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/opsconfigmonitoring.resourceMetadata.writer"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/logging.logWriter"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/monitoring.metricWriter"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/monitoring.dashboardEditor"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role "roles/kubernetesmetadata.publisher"
```


### Install `gkeadm`
```
mkdir ~/admin-ws
cd ~/admin-ws
```
```
gcloud storage cp gs://gke-on-prem-release/gkeadm/1.30.0-gke.1930/linux/gkeadm ./
chmod +x gkeadm
```

```
gcloud storage cp gs://gke-on-prem-release/gkeadm/1.30.0-gke.1930/linux/gkeadm.1.sig /tmp/gkeadm.1.sig
```
```
echo "-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWZrGCUaJJr1H8a36sG4UUoXvlXvZ
wQfk16sxprI2gOJ2vFFggdq3ixF2h4qNBt0kI7ciDhgpwS8t+/960IsIgw==
-----END PUBLIC KEY-----" > key.pem
openssl dgst -verify key.pem -signature /tmp/gkeadm.1.sig ./gkeadm
```

expect `Verified OK`

## Creating an admin workstation
```
./gkeadm create config
```

### fill yaml files
```
cat << EOF > credential.yaml
kind: CredentialFile
items:
- name: vCenter
username: "my-account-name"
password: "AadmpqGPqq!a"

EOF
```

```
true | openssl s_client -connect [vcenter_IP]:443 -showcerts 2>/dev/null | sed -ne '/-BEGIN/,/-END/p' > vcenter.pem
openssl x509 -in vcenter.pem -text -noout
```

```
vim admin-ws-config.yaml
```

### Grant roles to SDK account

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$ACCOUNT" \
  --role="roles/serviceusage.serviceUsageAdmin"
```

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$ACCOUNT" \
  --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$ACCOUNT" \
  --role="roles/iam.serviceAccountCreator"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$ACCOUNT" \
  --role="roles/iam.serviceAccountKeyAdmin"
```

#### Download and extract the Certification files
```bash
curl -k "https://SERVER_ADDRESS/certs/download.zip" > certs.zip
```

```bash
sudo apt-get install unzip
unzip certs.zip
```
```bash
sudo mkdir -p /usr/local/google/home/me/certs/ 
sudo cp certs/lin/c7069cea.0 /usr/local/google/home/me/certs/the-root.cert
```

### Create the admin workstation
```bash
cd ~/admin-ws
./gkeadm create admin-workstation --auto-create-service-accounts
```
```
ssh -i /home/asamy/.ssh/gke-admin-workstation ubuntu@172.16.32.10
```

## Create Admin Cluster


VM hostname | Description	| IP address
--- | --- | ---
admin-vm-1 |	Control-plane node for the admin cluster. |	172.16.32.50
admin-vm-2 |	Control-plane node for the admin cluster. |	172.16.32.51
admin-vm-3 |	Control-plane node for the admin cluster. |	172.16.32.52
user-vm-1 |	Control-plane node for the user cluster. |	172.16.32.53
user-vm-2 |	User cluster worker node |	172.16.32.54
user-vm-3 |	User cluster worker node |	172.16.32.55
user-vm-4 |	User cluster worker node |	172.16.32.56
user-vm-5 |		 | 172.16.32.57

VIP | Description | IP address
-- | -- | --
admin-cluster-VIP | VIP for the Kubernetes API server of the admin cluster, Configured on the load balancer for the admin cluster.    | 172.16.32.58 
user-cluster-VIP | VIP for the Kubernetes API server of the user cluster, Configured on the load balancer for the admin cluster.     | 172.16.32.59
Ingress VIP |	Configured on the load balancer for the user cluster. |	172.16.32.60
Service VIPs |	Ten addresses for Services of type LoadBalancer. Configured as needed on the load balancer for the user cluster. Notice that this range includes the ingress VIP. This is a requirement for the MetalLB load balancer. | 172.16.32.60 - 172.16.32.69

#### Enable GKE Hub API

https://console.developers.google.com/apis/api/gkehub.googleapis.com/overview?project=anthos-demo-project-0001
https://console.developers.google.com/apis/api/compute.googleapis.com/overview?project=anthos-demo-project-0001

```
gcloud projects list
gcloud config set project anthos-demo-project-0001
gcloud config get-value project

gcloud  billing accounts list

gcloud services enable cloudbilling.googleapis.com
gcloud billing projects link anthos-demo-project-0001 --billing-account=0155E4-692AAF-E2DDBE
```
```
gcloud beta billing projects link [PROJECT_ID] --billing-account=[ACCOUNT_ID]
```

```
gcloud services enable \
kubernetesmetadata.googleapis.com \
opsconfigmonitoring.googleapis.com \
compute.googleapis.com \
gkehub.googleapis.com \
container.googleapis.com \
anthos.googleapis.com \
connectgateway.googleapis.com \
cloudbilling.googleapis.com \
gkeonprem.googleapis.com
```

```
gcloud services enable --project $PROJECT_ID \
    anthos.googleapis.com \
    anthosgke.googleapis.com \
    anthosaudit.googleapis.com \
    cloudresourcemanager.googleapis.com \
    connectgateway.googleapis.com \
    container.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    gkeonprem.googleapis.com \
    kubernetesmetadata.googleapis.com \
    serviceusage.googleapis.com \
    stackdriver.googleapis.com \
    opsconfigmonitoring.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    iam.googleapis.com \
    storage.googleapis.com
```

#### Configure `admin-cluster.yaml`

```
more admin-cluster.yaml 
```
```yaml
---
apiVersion: v1
kind: AdminCluster
name: "minimal-installation-admin-cluster"
bundlePath: "/var/lib/gke/bundles/gke-onprem-vsphere-1.30.0-gke.1930-full.tgz"
vCenter:
  address: "vcf-vc-01.stc.cloud"
  datacenter: "VCF-LAB"
  cluster: "RUH-VCF-MGMT"
  resourcePool: "Anthos-SNB"
  datastore: "VCF-DS-VSAN01"
  caCertPath: "/home/ubuntu/the-root.cert"
  credentials:
    fileRef:
      path: "/home/ubuntu/credential.yaml"
      entry: "vCenter"
  folder: Abdul_Rahman
network:
  hostConfig:
    dnsServers:
    - "10.201.100.150"
    ntpServers:
    - "ntp.ubuntu.com"
  serviceCIDR: "10.96.232.0/24"
  podCIDR: "192.168.0.0/16"
  vCenter:
    networkName: "Management Networks/MGMT-VDS01/ASAMY-ANTHOS/ASAMY-ANTHOS"
  controlPlaneIPBlock:
    netmask: "255.255.255.0"
    gateway: "172.16.32.1"
    ips:
    - ip: "172.16.32.50"
      hostname: "admin-cp-vm-1"
    - ip: "172.16.32.51"
      hostname: "admin-cp-vm-2"
    - ip: "172.16.32.52"
      hostname: "admin-cp-vm-3"
loadBalancer:
  vips:
    controlPlaneVIP: "172.16.32.58"
  kind: "MetalLB"
adminMaster:
  cpus: 4
  memoryMB: 16384
  replicas: 3
antiAffinityGroups:
  enabled: false
componentAccessServiceAccountKeyPath: "component-access-key.json"
gkeConnect:
  projectID: "anthos-demo-project-0001"
  registerServiceAccountKeyPath: "connect-register-sa-2410061005.json"
stackdriver:
  projectID: "anthos-demo-project-0001"
  clusterLocation: "us-central1"
  enableVPC: false
  serviceAccountKeyPath: "log-mon-sa-2410061005.json"
  disableVsphereResourceMetrics: false
cloudAuditLogging:
  projectID: "anthos-demo-project-0001"
  clusterLocation: us-central1
  serviceAccountKeyPath: "AUDIT_LOG_SA_KEY"
autoRepair:
  enabled: true
osImageType: ubuntu_cgv2
```


```
gkectl check-config --config admin-cluster.yaml
```
```
gkectl prepare --config admin-cluster.yaml --skip-validation-all
```
```
gkectl create admin --config admin-cluster.yaml
```
```
kubectl get nodes --kubeconfig kubeconfig
```
```
gcloud container fleet memberships generate-gateway-rbac \
    --membership=minimal-installation-admin-cluster \
    --role=clusterrole/cluster-admin \
    --users=$GOOGLE_ACCOUNT_EMAIL \
    --project=$PROJECT_ID \
    --kubeconfig=kubeconfig \
    --context=minimal-installation-admin-cluster \
    --apply
```

```
gcloud container vmware clusters query-version-config \
    --project=$PROJECT_ID \
    --location=$REGION
```



#### Enroll admin cluster
```
gcloud container vmware admin-clusters enroll minimal-installation-admin-cluster \
    --project=$PROJECT_ID \
    --admin-cluster-membership=projects/$PROJECT_ID/locations/global/memberships/minimal-installation-admin-cluster \
    --location=$REGION
```

```
gcloud container vmware admin-clusters describe minimal-installation-admin-cluster \
  --project=$PROJECT_ID \
  --location=$REGION

```

```
PROJECT_NUMBER=998945032652
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:service-$PROJECT_NUMBER@gcp-sa-gkeonprem.iam.gserviceaccount.com" \
    --role "roles/gkeonprem.serviceAgent"

```

-j&FaR_5
A*bzSa@4


## Create user Cluster

```
vim user-ipblock.yaml
```

```yaml
blocks:
  - netmask: "255.255.255.0"
    gateway: "172.16.32.1"
    ips:
    - ip: "172.16.32.54"
      hostname: "user-vm-1"
    - ip: "172.16.32.55"
      hostname: "user-vm-2"
    - ip: "172.16.32.56"
      hostname: "user-vm-3"
    - ip: "172.16.32.57"
      hostname: "user-vm-4"
```

```
vim user-cluster.yaml
```
```yaml
apiVersion: v1
kind: UserCluster
name: "minimal-installation-user-cluster"
gkeOnPremVersion: "1.30.0-gke.1930"
enableControlplaneV2: true
network:
  hostConfig:
    dnsServers:
    - "10.201.100.150"
    ntpServers:
    - "ntp.ubuntu.com"
  ipMode:
    type: "static"
    ipBlockFilePath: "user-ipblock.yaml"
  serviceCIDR: "10.96.0.0/20"
  podCIDR: "192.168.0.0/16"
  controlPlaneIPBlock:
    netmask: "255.255.255.0"
    gateway: "172.16.32.1"
    ips:
    - ip: "172.16.32.53"
      hostname: "cp-vm-1"
loadBalancer:
  vips:
    controlPlaneVIP: "172.16.32.59"
    ingressVIP: "172.16.32.60"
  kind: "MetalLB"
  metalLB:
    addressPools:
    - name: "uc-address-pool"
      addresses:
      - "172.16.32.60/32"
      - "172.16.32.61/32"
      - "172.16.32.62/32"
      - "172.16.32.63/32"
      - "172.16.32.64/32"
      - "172.16.32.65/32"
      - "172.16.32.66/32"
      - "172.16.32.67/32"
      - "172.16.32.68/32"
      - "172.16.32.69/32"
enableDataplaneV2: true
nodePools:
- name: "uc-node-pool"
  cpus: 4
  memoryMB: 8192
  replicas: 3
  enableLoadBalancer: true
antiAffinityGroups:
  enabled: false
gkeConnect:
  projectID: "anthos-demo-project-0001"
  registerServiceAccountKeyPath: "connect-register-sa-2410061005.json"
stackdriver:
  projectID: "anthos-demo-project-0001"
  clusterLocation: "us-central1"
  enableVPC: false
  serviceAccountKeyPath: "log-mon-sa-2410061005.json"
  disableVsphereResourceMetrics: false
autoRepair:
  enabled: true
```


```
gkectl check-config --kubeconfig kubeconfig --config user-cluster.yaml
```

```
gkectl create cluster --kubeconfig kubeconfig --config user-cluster.yaml
```

```
kubectl get nodes --kubeconfig minimal-installation-user-cluster-kubeconfig
```

```
USER_CLUSTER_KUBECONFIG=minimal-installation-user-cluster-kubeconfig

gcloud container fleet memberships generate-gateway-rbac \
  --membership=minimal-installation-user-cluster \
  --role=clusterrole/cluster-admin \
  --users=$GOOGLE_ACCOUNT_EMAIL \
  --project=anthos-demo-project-0001 \
  --kubeconfig=$USER_CLUSTER_KUBECONFIG \
  --context=minimal-installation-user-cluster \
  --apply
```
```
```