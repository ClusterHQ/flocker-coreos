## Containerize Flocker parts.

## Steps

### setup

Setup the hostname and private key variables and create the folders needed

```
$ export COREOSHOST=XXX
$ export COREOSKEY=~/.ssh/XXX.pem
$ ssh -i ${COREOSKEY} core@${COREOSHOST} git clone https://github.com/clusterhq/flocker-coreos
$ ssh -i ${COREOSKEY} core@${COREOSHOST} mkdir -p /home/core/bakedcerts
$ ssh -i ${COREOSKEY} core@${COREOSHOST} sudo mkdir -p /flocker
```

### agent.yml
Write out `agent.yml` into `/home/core/bakedcerts`

```
$ cat /var/lib/flocker/node-etc-flocker/agent.yml
"version": 1
"control-service":
   "hostname": "xxx"
   "port": 4524
dataset:
    backend: "aws"
    region: "us-west-2"
    zone: "us-west-2b"
    access_key_id: "xxxx"
    secret_access_key: "xxx"
```

### certs
Here are the steps to generate the certs (from your local machine where you need flocker-ca installed):

```
$ mkdir tempcerts
$ cd tempcerts
$ flocker-ca initialize coreostest
$ flocker-ca create-control-certificate $COREOSHOST
$ flocker-ca create-node-certificate
$ flocker-ca create-api-certificate coreuser
$ mv XXX.crt node.crt
$ mv XXX.key node.key
$ mv control-${COREOSHOST}.crt control-service.crt
$ mv control-${COREOSHOST}.key control-service.key
$ scp -i ${COREOSKEY} * core@${COREOSHOST}:/home/core/bakedcerts
```

### build images

Now we run the image build script:

```
$ ssh -i ${COREOSKEY} core@${COREOSHOST}
coreos$ cd ~/flocker-coreos/flocker-bits
coreos$ sh buildimages.sh
```

### run containers

```
CERTS=/home/core/bakedcerts

docker run --net=host --privileged \
    -v /:/host -v $CERTS:/etc/flocker \
    -v /dev:/dev -v /var/run/docker.sock:/var/run/docker.sock -d \
    clusterhq/flocker-container-agent

docker run --net=host --privileged \
    -v /:/host -v $CERTS:/etc/flocker \
    -v /dev:/dev -v /var/run/docker.sock:/var/run/docker.sock -d \
    clusterhq/flocker-dataset-agent

docker run --net=host --privileged -p 4523-4524:4523-4524 \
    -v /:/host -v $CERTS:/etc/flocker \
    -d clusterhq/flocker-control-service
```

### DEBUG

There is a DEBUG flag that will log all wrapped nsenter commands to `/tmp/flocker-command-log`.

To activate this - set the `DEBUG` env to true and mount `/tmp/flocker-command-log`:

```
CERTS=/home/core/bakedcerts

docker run --net=host --privileged \
    -v /:/host -v $CERTS:/etc/flocker \
    -e DEBUG=1 \
    -v /tmp/flocker-command-log:/tmp/flocker-command-log \
    -v /dev:/dev -v /var/run/docker.sock:/var/run/docker.sock -d \
    clusterhq/flocker-dataset-agent
```

### volume cli wrapper

```
mkdir ~/bin
LOCAL_IP=10.164.167.217
USER=coreuser
echo > ~/bin/flocker-volumes <<EOF
#!/bin/sh
docker run -v $CERTS:/flockercerts -ti clusterhq/flocker-tools flocker-volumes \
    --certs-path=/flockercerts --user=coreuser --control-service=$LOCAL_IP $@
EOF
chmod +x ~/bin/flocker-volumes
~/bin/flocker-volumes list-nodes
```
