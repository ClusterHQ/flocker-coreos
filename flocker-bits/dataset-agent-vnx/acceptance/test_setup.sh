#!/bin/sh

set -ex

CLUSTER_ID="FLOCKER_${RANDOM}"
CONTROL_NODE_ADDRESS="172.20.20.102"
NODE1_ADDRESS="172.20.20.102"
NODE1_VNX_NAME="esx08.ashqe"
NODE1_VNX_STORAGE_GROUP="Docker100"

NODE2_ADDRESS="172.20.20.103"
NODE2_VNX_NAME="esx07.ashqe"
NODE2_VNX_STORAGE_GROUP="Docker101"

WORKING_DIR="$(mktemp --directory --tmpdir=${PWD} flocker_coreos_demo.XXXXXXXXXX)"
pushd "${WORKING_DIR}"

# Cluster certificate authority
flocker-ca initialize "${CLUSTER_ID}"

# Create an API certificate
flocker-ca create-api-certificate user1

# Node 1
mkdir -p "${NODE1_ADDRESS}"
flocker-ca create-node-certificate "--outputpath=${NODE1_ADDRESS}"
pushd "${NODE1_ADDRESS}"
mv {*,node}.key
mv {*,node}.crt
popd

# Node 2
mkdir "${NODE2_ADDRESS}"
flocker-ca create-node-certificate "--outputpath=${NODE2_ADDRESS}"
pushd "${NODE2_ADDRESS}"
mv {*,node}.key
mv {*,node}.crt
popd

# Control service
mkdir -p "${CONTROL_NODE_ADDRESS}"
flocker-ca create-control-certificate --outputpath="${CONTROL_NODE_ADDRESS}" "${CONTROL_NODE_ADDRESS}"
pushd "${CONTROL_NODE_ADDRESS}"
mv control-{${CONTROL_NODE_ADDRESS},service}.key
mv control-{${CONTROL_NODE_ADDRESS},service}.crt
popd

# Copy CA crt to everyone
sudo cp cluster.crt "${NODE1_ADDRESS}"
sudo cp cluster.crt "${NODE2_ADDRESS}"

# Creat agent.yml
cat <<EOF > "${NODE1_ADDRESS}/agent.yml"
version: 1
control-service:
  hostname: "${CONTROL_NODE_ADDRESS}"
dataset:
  backend: "flocker_emc_vnx_driver"
  spa_ip: "192.168.40.13"
  storage_pool: "Docker_Block_Pool"
  naviseccli_keys: "/etc/flocker/keys"
  hostname: "${NODE1_VNX_NAME}"
  storage_group: "${NODE1_VNX_STORAGE_GROUP}"
EOF

cat <<EOF > "${NODE2_ADDRESS}/agent.yml"
version: 1
control-service:
  hostname: "${CONTROL_NODE_ADDRESS}"
dataset:
  backend: "flocker_emc_vnx_driver"
  spa_ip: "192.168.40.13"
  storage_pool: "Docker_Block_Pool"
  naviseccli_keys: "/etc/flocker/keys"
  hostname: "${NODE2_VNX_NAME}"
  storage_group: "${NODE2_VNX_STORAGE_GROUP}"
EOF

# cluster.crt is owned by root and 600 which prevents us copying it. Fix that.
sudo chown -R "${USER}:${USER}" "${NODE1_ADDRESS}" "${NODE2_ADDRESS}"

# Upload config
rsync --delete -av "${NODE1_ADDRESS}/" "core@${NODE1_ADDRESS}":etc_flocker
rsync --delete -av "${NODE2_ADDRESS}/" "core@${NODE2_ADDRESS}":etc_flocker

echo $WORKING_DIR
