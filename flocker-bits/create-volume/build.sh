#!/bin/bash

set -e

docker build -t clusterhq/create-volume:1.2.0-1rev1 .
docker run -ti --rm \
    --volumes-from certs \
    -e FLOCKER_API_CERT_NAME=plugin \
    -e FLOCKER_CONTROL_SERVICE_ENDPOINT=54.158.226.17 \
    clusterhq/create-volume:1.2.0-1rev1 \
    --dataset-uuid 11111111-1111-1111-1111-111111111129 \
    --host-uuid 9cd4dfba-2bd6-44de-ab49-daa209afe02b \
    --size 67108864

