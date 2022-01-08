#!/bin/bash

if [ -z "${REPOSITORY_PREFIX}" ]
then 
    echo "Please set the REPOSITORY_PREFIX"
else 
    cat ./k8s/*.yaml | \
    sed 's#\${REPOSITORY_PREFIX}'"#${REPOSITORY_PREFIX}#g" | \
    sed 's#\${TAG}'"#${TAG}#g" | \
    kubectl apply -f -
fi
