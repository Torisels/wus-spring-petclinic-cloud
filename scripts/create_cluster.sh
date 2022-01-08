#!/bin/sh
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')

# enable needed APIs
gcloud services enable \
cloudapis.googleapis.com \
container.googleapis.com \
--project=$PROJECT_ID

gcloud container clusters create ${CLUSTER_NAME} \
--project=$PROJECT_ID \
--enable-ip-alias \
--scopes=cloud-platform \
--num-nodes=3 \
--machine-type=e2-small \
--disk-size=20GB \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM
