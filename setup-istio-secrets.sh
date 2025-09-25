#!/bin/bash


CLUSTER_01_SUFIX="c1"
CLUSTER_01_NAME="kind-${CLUSTER_01_SUFIX}"

CLUSTER_02_SUFIX="c2"
CLUSTER_02_NAME="kind-${CLUSTER_02_SUFIX}"


function main {
    echo "Generating secrets from cluster 01 and applying in cluster 02"
    istioctl create-remote-secret \
        --context="${CLUSTER_01_NAME}" \
        --name="${CLUSTER_01_NAME}" | \
        kubectl apply -f - --context="${CLUSTER_02_NAME}"

    echo "Generating secrets from cluster 02 and applying in cluster 01"
    istioctl create-remote-secret \
        --context="${CLUSTER_02_NAME}" \
        --name="${CLUSTER_02_NAME}" | \
        kubectl apply -f - --context="${CLUSTER_01_NAME}"
}


main
