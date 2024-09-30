# Anthos installation

## bootstrap machine preparation:

### Install `gcloud CLI`


mkdir ~/gcloud-cli
cd ~/gcloud-cli

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz

tar -xf google-cloud-cli-linux-x86_64.tar.gz

./google-cloud-sdk/install.sh


gcloud config get-value account
gcloud auth login


### Install `gkeadm`
mkdir ~/admin-ws
cd ~/admin-ws

gcloud storage cp gs://gke-on-prem-release/gkeadm/1.30.0-gke.1930/linux/gkeadm ./
chmod +x gkeadm



gcloud storage cp gs://gke-on-prem-release/gkeadm/1.30.0-gke.1930/linux/gkeadm.1.sig /tmp/gkeadm.1.sig
echo "-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWZrGCUaJJr1H8a36sG4UUoXvlXvZ
wQfk16sxprI2gOJ2vFFggdq3ixF2h4qNBt0kI7ciDhgpwS8t+/960IsIgw==
-----END PUBLIC KEY-----" > key.pem
openssl dgst -verify key.pem -signature /tmp/gkeadm.1.sig ./gkeadm


./gkeadm create config


cat << EOF > credential.yaml
kind: CredentialFile
items:
- name: vCenter
username: "my-account-name"
password: "AadmpqGPqq!a"

EOF

vim admin-ws-config.yaml