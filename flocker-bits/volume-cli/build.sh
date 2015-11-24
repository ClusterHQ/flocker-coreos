#!/bin/bash

set -e

sudo docker build -t clusterhq/volume-cli:1.7.2 .
sudo docker run -ti --rm \
    --volumes-from certs \
    -e FLOCKER_API_CERT_NAME=plugin \
    -e FLOCKER_CONTROL_SERVICE_ENDPOINT=10.154.243.239 \
    clusterhq/volume-cli:1.7.2 \
    --dataset-name apples2 \
    --size-units GB \
    --size 2 \
    --host-uuid bcdeb7d5-5c0f-466e-ae14-7976cdc277a5
