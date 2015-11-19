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

# Start Mysql container on 102
ssh core@172.20.20.102

lsblk

read -p "Enter Dataset path: " DATASET_PATH

docker run \
    --interactive \
    --tty \
    --rm  \
    --publish-all \
    --volume "${DATASET_PATH}/data:/var/lib/mysql" \
    --env MYSQL_ROOT_PASSWORD=secret \
    mysql:latest

# Discover remote port
ssh core@172.20.20.102 docker ps | grep mysql

# Connect to MySQL
mysql --host 172.20.20.102 --port 32770 --user root --password

# Create database
create database salesforce1;

# Stop database
ssh core@172.20.20.102 docker ps | grep mysql

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


# Start Mysql container on 103
ssh core@172.20.20.103

lsblk

read -p "Enter Dataset path: " DATASET_PATH

docker run \
    --interactive \
    --tty \
    --rm  \
    --publish-all \
    --volume "${DATASET_PATH}/data:/var/lib/mysql" \
    --env MYSQL_ROOT_PASSWORD=secret \
    mysql:latest

# Discover remote port
ssh core@172.20.20.103 docker ps | grep mysql

read -p "Enter MySQL port: " MYSQL_PORT

# Connect to MySQL
mysql --host 172.20.20.103 --port "${MYSQL_PORT}" --user root --password
