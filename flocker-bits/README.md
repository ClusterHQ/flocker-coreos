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

TODO make a docker volume container for the control service state!

```
CERTS=/home/core/bakedcerts
touch /tmp/flocker-command-log

docker run -d --net=host -v $CERTS:/etc/flocker \
    -v /var/run/docker.sock:/var/run/docker.sock \
    clusterhq/flocker-container-agent

docker run --net=host --privileged \
    -e DEBUG=1 \
    -v /tmp/flocker-command-log:/tmp/flocker-command-log \
    -v /flocker:/flocker -v /:/host -v $CERTS:/etc/flocker \
    -v /dev:/dev -d \
    clusterhq/flocker-dataset-agent

docker run -d --net=host -v $CERTS:/etc/flocker \
    clusterhq/flocker-control-service
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

