#!/bin/bash
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')

# enable needed APIs
gcloud services enable \
cloudapis.googleapis.com \
container.googleapis.com \
--project=${CLOUDSDK_CORE_PROJECT}

gcloud container clusters create ${CLUSTER_NAME} \
--project=${CLOUDSDK_CORE_PROJECT} \
--enable-ip-alias \
--scopes=cloud-platform \
--num-nodes=4 \
--machine-type=e2-medium \
--disk-size=20GB \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM
