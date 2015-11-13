#!/bin/bash

export CURL="curl --silent --cacert $PWD/cluster.crt --cert $PWD/user1.crt --key $PWD/user1.key"

# List empty dataset config
$CURL https://172.20.20.102:4523/v1/configuration/datasets | jq '.'

# List empty dataset state
$CURL https://172.20.20.102:4523/v1/state/datasets | jq '.'

# List nodes
$CURL https://172.20.20.102:4523/v1/state/nodes | jq '.'

# Create a dataset on NODE1
read -p "Enter NODE1 UUID: " NODE1_UUID
$CURL \
    -XPOST \
    -d '@-' \
    https://172.20.20.102:4523/v1/configuration/datasets <<EOF
{
    "primary": "${NODE1_UUID}",
    "maximum_size": 4294967296
}
EOF

# List new dataset config
$CURL https://172.20.20.102:4523/v1/configuration/datasets | jq '.'

# List converged dataset state
$CURL https://172.20.20.102:4523/v1/state/datasets | jq '.'
read -p "Enter Dataset UUID: " DATASET_UUID

# Move dataset to NODE2
$CURL https://172.20.20.102:4523/v1/state/nodes | jq '.'
read -p "Enter NODE2 UUID: " NODE2_UUID
$CURL \
     -XPOST \
     -d '@-' \
     "https://172.20.20.102:4523/v1/configuration/datasets/${DATASET_UUID}" <<EOF
{
    "primary": "${NODE2_UUID}"
}
EOF

# List converged dataset state
$CURL https://172.20.20.102:4523/v1/state/datasets | jq '.'
