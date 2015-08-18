## Containerize Flocker CA.


## Steps:

 * Run `flocker-ca` on your local machine to generate node, cluster and control-service certs.
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
