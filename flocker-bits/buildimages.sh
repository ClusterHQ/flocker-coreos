#!/bin/sh
docker build -t clusterhq/flocker-core flocker-core
docker build -t clusterhq/flocker-container-agent container-agent
docker build -t clusterhq/flocker-control-service control-agent
docker build -t clusterhq/flocker-dataset-agent dataset-agent
docker build -t clusterhq/flocker-tools flocker-tools