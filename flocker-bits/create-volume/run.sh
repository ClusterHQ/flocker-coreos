#!/bin/bash

set -e

# no FLOCKER_API_CERT_NAME has been given
# so we generate a user.{crt,key}
if [[ -z "$FLOCKER_API_CERT_NAME" ]]; then
    echo "Generating certs for the create volume script"
    FLOCKER_API_CERT_NAME=user

    echo "Generating api certificate for create volume script"
    mkdir /tmp/flocker
    flocker-ca create-api-certificate --inputpath=/etc/flocker --outputpath=/tmp/flocker $FLOCKER_API_CERT_NAME

    echo "Fixing file permissions and filenames for certificate"
    chmod 0600 /tmp/flocker/*
    mv /tmp/flocker/$FLOCKER_API_CERT_NAME.crt /etc/flocker/$FLOCKER_API_CERT_NAME.crt
    mv /tmp/flocker/$FLOCKER_API_CERT_NAME.key /etc/flocker/$FLOCKER_API_CERT_NAME.key
fi

echo "Running volume create script"
exec /opt/flocker/bin/python /opt/flocker/script.py $@