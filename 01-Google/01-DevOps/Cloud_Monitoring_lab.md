

```
sudo apt-get update
sudo apt-get install -y apache2 php7.0
sudo service apache2 restart
```

```
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh

sudo bash add-google-cloud-ops-agent-repo.sh --also-install

sudo apt-get update

sudo systemctl status google-cloud-ops-agent"*"
```