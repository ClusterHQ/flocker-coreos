## Containerize Flocker parts.

## Steps

 * Run `flocker-ca` on your local machine to generate node, cluster and control-service certs.
 * mkdir `/flocker` on CoreOS host.
 * Copy them to your CoreOS node, e.g. `/home/core/bakedcerts` below.
 * Write out `agent.yml` in same directory.

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
#!/bin/sh                                                                                                        |
docker run -v $CERTS:/flockercerts -ti clusterhq/flocker-dataset-agent flocker-volumes --certs-path=/flockercerts --user=coreuser --control-service=10.164.167.217 $@
EOF
```
