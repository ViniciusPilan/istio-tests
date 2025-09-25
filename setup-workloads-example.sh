#!/bin/bash


CLUSTER_01_SUFIX="c1"
CLUSTER_01_NAME="kind-${CLUSTER_01_SUFIX}"

CLUSTER_02_SUFIX="c2"
CLUSTER_02_NAME="kind-${CLUSTER_02_SUFIX}"


function main {
    echo "Instaling test workloads in Cluster 01"
    kubectl apply -f example/test-server.yaml --context=${CLUSTER_01_NAME}
    kubectl apply -f example/cluster01 --context=${CLUSTER_01_NAME}

    echo "Instaling test workloads in Cluster 02"
    kubectl apply -f example/test-server.yaml --context=${CLUSTER_02_NAME}
    kubectl apply -f example/cluster02 --context=${CLUSTER_02_NAME}
}


main
