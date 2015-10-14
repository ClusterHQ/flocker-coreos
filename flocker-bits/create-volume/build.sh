#!/bin/bash

set -e

sudo docker build -t clusterhq/create-volume:1.2.0-1rev1 .
sudo docker run -ti --rm \
    --volumes-from certs \
    -e FLOCKER_API_CERT_NAME=plugin \
    -e FLOCKER_CONTROL_SERVICE_ENDPOINT=10.154.243.239 \
    clusterhq/create-volume:1.2.0-1rev1 \
    --dataset-uuid 11111111-1111-1111-1111-111111111133 \
    --size-units gb \
    --size 2 \
    --host-uuid bcdeb7d5-5c0f-466e-ae14-7976cdc277a5

