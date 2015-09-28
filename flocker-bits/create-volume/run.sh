#!/bin/bash

set -e

echo "Generating certs for the create volume script"

echo "Generating api certificate for create volume script"
mkdir /tmp/flocker
flocker-ca create-api-certificate --inputpath=/etc/flocker --outputpath=/tmp/flocker user

echo "Fixing file permissions and filenames for certificate"
chmod 0600 /tmp/flocker/*
mv /tmp/flocker/user.crt /etc/flocker/user.crt
mv /tmp/flocker/user.key /etc/flocker/user.key

echo "Running volume create script"
exec /opt/flocker/bin/python /opt/flocker/script.py $@