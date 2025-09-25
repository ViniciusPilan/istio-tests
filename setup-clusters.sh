#!/bin/bash


CLUSTER_01_SUFIX="c1"
CLUSTER_01_NAME="kind-${CLUSTER_01_SUFIX}"

CLUSTER_02_SUFIX="c2"
CLUSTER_02_NAME="kind-${CLUSTER_02_SUFIX}"


# Creates the two clusters of the lab
function create_clusters {
    echo "----------------------------------------------------------------------------------"
    echo "Creating clusters"
    kind create cluster --name=${CLUSTER_01_SUFIX} --config=cluster-config.yaml
    kind create cluster --name=${CLUSTER_02_SUFIX} --config=cluster-config.yaml

    echo "----------------------------------------------------------------------------------"
    echo "Waiting clusters be ready"
    kubectl wait --for create node/c1-control-plane --timeout=60s --context=${CLUSTER_01_NAME}
    kubectl wait --for create node/c2-control-plane --timeout=60s --context=${CLUSTER_02_NAME}

    echo "----------------------------------------------------------------------------------"
    echo "Creating namespaces in both clusters"
    kubectl apply -f namespaces-cluster01.yaml --context=${CLUSTER_01_NAME}
    kubectl apply -f namespaces-cluster02.yaml --context=${CLUSTER_02_NAME}
}

# Setup ArgoCD in both clusters of this lab
function install_argo {
    cd argocd

    echo "----------------------------------------------------------------------------------"
    echo "Installing argocd in the clusters"
    kubectl apply -f install/install.yaml -n argocd --context=${CLUSTER_01_NAME}
    kubectl apply -f install/install.yaml -n argocd --context=${CLUSTER_02_NAME}

    echo "----------------------------------------------------------------------------------"
    echo "Waiting password secrets creation in both clusters"
    kubectl wait --for create secret/argocd-initial-admin-secret -n argocd --timeout=60s --context=${CLUSTER_01_NAME}
    kubectl wait --for create secret/argocd-initial-admin-secret -n argocd --timeout=60s --context=${CLUSTER_02_NAME}

    echo "----------------------------------------------------------------------------------"
    echo "Command to expose ArgoCD" 
    echo "kubectl port-forward svc/argocd-server 8081:80 -n argocd --context=${CLUSTER_01_NAME}"
    echo "kubectl port-forward svc/argocd-server 8082:80 -n argocd --context=${CLUSTER_02_NAME}"

    echo "----------------------------------------------------------------------------------"
    echo "Credentials to access ArgoCD:"
    echo "Argo user: admin"
    echo "Argo password (c1): $(kubectl get secrets --context=${CLUSTER_01_NAME} -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)"
    echo "Argo password (c2): $(kubectl get secrets --context=${CLUSTER_02_NAME} -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)"
    
    echo "----------------------------------------------------------------------------------"
    echo "Waiting argocd be ready in both clusters"
    kubectl wait --for create deploy/argocd-server -n argocd --timeout=60s --context=${CLUSTER_01_NAME}
    kubectl wait --for create deploy/argocd-server -n argocd --timeout=60s --context=${CLUSTER_02_NAME}

    echo "----------------------------------------------------------------------------------"
    echo "Creating applications in both clusters"
    kubectl apply -f applications/istio-c1.yaml --context=${CLUSTER_01_NAME}
    kubectl apply -f applications/istio-c2.yaml --context=${CLUSTER_02_NAME}

    cd -
}

function main {
    create_clusters
    install_argo
}


main
