#!/bin/sh

set -ex

TAG="1.5.0-1rev1"
CLUSTER_ID="FLOCKER_${RANDOM}"
CONTROL_NODE_ADDRESS="172.20.20.102"
NODE1_ADDRESS="172.20.20.102"
NODE1_VNX_NAME="esx08.ashqe"
NODE1_VNX_STORAGE_GROUP="Docker100"

NODE2_ADDRESS="172.20.20.103"
NODE2_VNX_NAME="esx07.ashqe"
NODE2_VNX_STORAGE_GROUP="Docker101"

NAVISECCLI_HOSTNAME="595ed7236199"
NAVISECCLI_KEYS_FILENAME="navisecclisec.595ed7236199.20151111.zip"
NAVISECCLI_KEYS="/home/richard/projects/HybridLogic/${NAVISECCLI_KEYS_FILENAME}"

flocker-ca() {
    docker run --rm -it "--volume=${PWD}:/data" --workdir=/data "clusterhq/flocker-core:${TAG}" flocker-ca $@
}

WORKING_DIR="$(mktemp --directory --tmpdir=${PWD} flocker_coreos_demo.XXXXXXXXXX)"
pushd "${WORKING_DIR}"

# Cluster certificate authority
flocker-ca initialize "${CLUSTER_ID}"

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
  backend: "vnx_flocker_driver"
  spa_ip: "192.168.40.13"
  storage_pool: "Docker_Block_Pool"
  naviseccli_keys: "/keys"
  hostname: "${NODE1_VNX_NAME}"
  storage_group: "${NODE1_VNX_STORAGE_GROUP}"
EOF

cat <<EOF > "${NODE2_ADDRESS}/agent.yml"
version: 1
control-service:
  hostname: "${CONTROL_NODE_ADDRESS}"
dataset:
  backend: "vnx_flocker_driver"
  spa_ip: "192.168.40.13"
  storage_pool: "Docker_Block_Pool"
  naviseccli_keys: "/keys"
  hostname: "${NODE2_VNX_NAME}"
  storage_group: "${NODE2_VNX_STORAGE_GROUP}"
EOF

# Set up a hostname file
echo "${NAVISECCLI_HOSTNAME}" > "${NODE1_ADDRESS}/hostname"
echo "${NAVISECCLI_HOSTNAME}" > "${NODE2_ADDRESS}/hostname"

# cluster.crt is owned by root and 600 which prevents us copying it. Fix that.
sudo chown -R "${USER}:${USER}" "${NODE1_ADDRESS}" "${NODE2_ADDRESS}"

# Upload config
scp -r "${NODE1_ADDRESS}" "core@${NODE1_ADDRESS}":etc_flocker
scp -r "${NODE2_ADDRESS}" "core@${NODE2_ADDRESS}":etc_flocker

scp -r "${NAVISECCLI_KEYS}" "core@${NODE1_ADDRESS}":
ssh "core@${NODE1_ADDRESS}" unzip "${NAVISECCLI_KEYS_FILENAME}"

scp -r "${NAVISECCLI_KEYS}" "core@${NODE2_ADDRESS}":
ssh "core@${NODE2_ADDRESS}" unzip "${NAVISECCLI_KEYS_FILENAME}"
