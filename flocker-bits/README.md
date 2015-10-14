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

**IMPORTANT** - make sure that all your nodes are in the same zone, and update 'zone' below for the specific zone that all your nodes are in

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

TODO make a docker volume container for the control service state!

```
docker rm -f flocker-control-service flocker-container-agent flocker-dataset-agent
CERTS=/home/core/bakedcerts
touch /tmp/flocker-command-log

docker run -d --net=host -v $CERTS:/etc/flocker \
    --name=flocker-control-service \
    clusterhq/flocker-control-service

docker run -d --net=host --privileged \
    -v $CERTS:/etc/flocker \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name=flocker-container-agent \
    clusterhq/flocker-container-agent

docker run --net=host --privileged -d \
    -e DEBUG=1 \
    -v /tmp/flocker-command-log:/tmp/flocker-command-log \
    -v /flocker:/flocker \
    -v /:/host \
    -v $CERTS:/etc/flocker \
    -v /dev:/dev \
    --name=flocker-dataset-agent \
    clusterhq/flocker-dataset-agent

# this creates a volume
docker run -ti --rm \
    --volumes-from certs \
    -e FLOCKER_CONTROL_SERVICE_ENDPOINT=172.16.79.250 \
    -e FLOCKER_API_CERT_NAME=bob # -> /etc/flocker/bob.{crt,key}
    clusterhq/create-volume:1.2.0-1rev1 \
    --dataset-uuid 11111111-1111-1111-1111-111111111124 \
    --host-uuid 5c2aee8e-71c0-46cb-8338-02a59e935cbc \
    --size-units GB \
    --size 2

# this detaches a volume
docker run -ti --rm \
    --volumes-from certs \
    -e FLOCKER_CONTROL_SERVICE_ENDPOINT=172.16.79.250 \
    -e FLOCKER_API_CERT_NAME=bob # -> /etc/flocker/bob.{crt,key}
    clusterhq/create-volume:1.2.0-1rev1 \
    --dataset-uuid 11111111-1111-1111-1111-111111111124 \
    --host-uuid none
```

### DEBUG

There is a DEBUG flag that will log all wrapped nsenter commands to `/tmp/flocker-command-log`.

To activate this - set the `DEBUG` env to true and mount `/tmp/flocker-command-log` when running the dataset agent, as shown above.
To disable, unset DEBUG=1.


### volume cli wrapper

```
LOCAL_IP=10.164.167.217 # XXX SET THIS (see ifconfig eth0 output)
mkdir ~/bin
USER=coreuser
cat > ~/bin/flocker-volumes <<EOF
#!/bin/sh
docker run -v $CERTS:/flockercerts -ti clusterhq/flocker-tools flocker-volumes \\
    --certs-path=/flockercerts --user=coreuser --control-service=$LOCAL_IP \$@
EOF
chmod +x ~/bin/flocker-volumes
~/bin/flocker-volumes list-nodes
```

### testing
```
core@ip-10-183-35-14 ~/bin $ ./flocker-volumes list-nodes
SERVER     ADDRESS
336dba8b   10.183.35.14
core@ip-10-183-35-14 ~/bin $ ./flocker-volumes create -n 336dba8b -s 10G
```

### debugging flocker
```
wget https://raw.githubusercontent.com/ClusterHQ/eliot/error-output-proto/error-extract.py
docker logs flocker-dataset-agent | docker run \
    -i -v $PWD:/app python python /app/error-extract.py
```
