# Istio tests

## Multicluster
Approach: [Multi Primary multi network](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/)


## Requirements
- Docker
- Kind

## How to reproduce
Create two Kind clusters, installing ArgoCD and creating an Application to install Istio components via Helm:
```sh
$ bash setup-clusters.sh
```
After the script execution, you will see a command to help you in the ArgoCD web UI access (that is not public by default and requires authentication). So, use the command to port-forward and use the credentials (user is `admin` for both clusters, but the password is different for each one).

Go to ArgoCD of each cluster and sync Istio components to install **Istio CRDs**, **Istiod**, and **Gateway**.

Now, generate and install the necessary secrets for the multicluster mesh:
```sh
$ bash setup-istio-secrets.sh
```

Now, you are able to test the multicluster connection.

You can validade the mesh using the following command:
```sh
# In cluster 01
istioctl remote-clusters --context="kind-c1"

# In cluster 02
istioctl remote-clusters --context="kind-c2"
```
