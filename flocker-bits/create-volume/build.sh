#!/bin/bash

set -e

docker build -t clusterhq/create-volume:1.2.0-1rev1 .
docker run -ti --rm \
    --volumes-from certs \
    -e FLOCKER_API_CERT_NAME=plugin \
    -e FLOCKER_CONTROL_SERVICE_ENDPOINT=172.16.79.250 \
    clusterhq/create-volume:1.2.0-1rev1 \
    --dataset-uuid 11111111-1111-1111-1111-111111111125 \
    --host-uuid 5c2aee8e-71c0-46cb-8338-02a59e935cbc \
    --size 67108864

