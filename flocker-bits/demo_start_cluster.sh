#!/bin/bash

# Start control service
docker run --rm \
       --net=host \
       --volume $PWD/etc_flocker:/etc/flocker \
       --name=flocker-control \
       clusterhq/flocker-control-service:1.5.0-1rev1

# Start container agent
docker run --rm \
       --net=host \
       --privileged \
       --volume $PWD/etc_flocker:/etc/flocker \
       --volume /var/run/docker.sock:/var/run/docker.sock \
       --name=flocker-container-agent  \
       clusterhq/flocker-container-agent:1.5.0-1rev1

# Start dataset agent
docker run --rm \
       --privileged \
       --net=host \
       --volume /:/host \
       --volume $PWD/etc_flocker:/etc/flocker \
       --volume /dev:/dev \
       --volume /home/core/navisecclisec:/keys \
       --volume /flocker:/flocker \
       --volume $PWD/flocker-vnx-driver:/flocker-vnx-driver \
       --name=flocker-dataset-agent \
       clusterhq/flocker-dataset-agent:1.5.0-1rev1
