#!/bin/sh
FLOCKER_TAG=1.5.0-1rev1
docker build -t clusterhq/flocker-core:$FLOCKER_TAG flocker-core
docker build -t clusterhq/flocker-container-agent:$FLOCKER_TAG container-agent
docker build -t clusterhq/flocker-control-service:$FLOCKER_TAG control-agent
docker build -t clusterhq/flocker-dataset-agent:$FLOCKER_TAG dataset-agent
docker build -t clusterhq/flocker-tools:$FLOCKER_TAG flocker-tools
