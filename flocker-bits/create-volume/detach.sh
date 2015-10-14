#!/bin/bash

set -e

sudo docker build -t clusterhq/create-volume:1.2.0-1rev1 .
sudo docker run -ti --rm \
    --volumes-from certs \
    -e FLOCKER_API_CERT_NAME=plugin \
    -e FLOCKER_CONTROL_SERVICE_ENDPOINT=10.154.243.239 \
    clusterhq/create-volume:1.2.0-1rev1 \
    --dataset-name apples \
    --host-uuid none

