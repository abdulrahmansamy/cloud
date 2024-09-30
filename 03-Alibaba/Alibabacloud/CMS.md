```
cd /tmp/

ARGUS_VERSION=3.5.10 /bin/bash -c "$(curl -s https://cms-agent-me-central-1.oss-me-central-1-internal.aliyuncs.com/Argus/agent_install_ecs-1.7.sh)"

wget http://logtail-release-cn-hangzhou.oss-cn-hangzhou.aliyuncs.com/linux64/logtail.sh -O logtail.sh; chmod 755 logtail.sh; bash logtail.sh install me-central-1

cd -

```