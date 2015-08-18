## Containerize Flocker parts.

## Steps

 * Run `flocker-ca` on your local machine to generate node, cluster and control-service certs.
 * mkdir `/flocker` on CoreOS host.
 * Copy them to your CoreOS node, e.g. `/home/core/bakedcerts` below.
 * Write out `agent.yml` in same directory.

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

Here are the steps to generate the certs:

```
$ export COREOSHOST=XXX
$ export COREOSKEY=~/.ssh/XXX.pem
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
$ ssh -i ${COREOSKEY} core@${COREOSHOST} mkdir -p /home/core/bakedcerts
$ scp -i ${COREOSKEY} * core@${COREOSHOST}:/home/core/bakedcerts
```

Run:

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

Create a wrapper:

```
mkdir ~/bin
LOCAL_IP=10.164.167.217
USER=coreuser
echo > ~/bin/flocker-volumes <<EOF
#!/bin/sh
docker run -v $CERTS:/flockercerts -ti clusterhq/flocker-dataset-agent flocker-volumes \
    --certs-path=/flockercerts --user=coreuser --control-service=$LOCAL_IP $@
EOF
chmod +x ~/bin/flocker-volumes
~/bin/flocker-volumes list-nodes
```
