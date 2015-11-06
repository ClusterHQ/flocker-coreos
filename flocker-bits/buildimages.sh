#!/bin/sh
FLOCKER_TAG=1.6.1-1rev1
docker build -t clusterhq/flocker-core:$FLOCKER_TAG flocker-core
docker build -t clusterhq/flocker-container-agent:$FLOCKER_TAG container-agent
docker build -t clusterhq/flocker-control-service:$FLOCKER_TAG control-agent
docker build -t clusterhq/flocker-dataset-agent:$FLOCKER_TAG dataset-agent
docker build -t clusterhq/flocker-tools:$FLOCKER_TAG flocker-tools
docker build -t clusterhq/flocker-docker-plugin:$FLOCKER_TAG docker-plugin
