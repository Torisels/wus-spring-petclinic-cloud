#!/bin/sh

gcloud iam service-accounts create gha-deploy --project=${CLOUDSDK_CORE_PROJECT}

export SA_EMAIL="gha-deploy@${CLOUDSDK_CORE_PROJECT}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding ${CLOUDSDK_CORE_PROJECT} \
--member=serviceAccount:${SA_EMAIL} \
--role=roles/container.admin

gcloud projects add-iam-policy-binding ${CLOUDSDK_CORE_PROJECT} \
--member=serviceAccount:${SA_EMAIL} \
--role=roles/container.clusterViewer

gcloud iam service-accounts keys create key.json \
--iam-account=${SA_EMAIL} \
--project=${CLOUDSDK_CORE_PROJECT}
