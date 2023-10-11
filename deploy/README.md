# Description
The following folder contain the Kubernetes manifest files needed to deploy the Airlock Microgateway.
* `charts`: Contains Helm charts for certain Airlock Microgateway components
* `cni`: Contains example Kustomize folders and `values.yaml` files for deploying the Airlock Microgateway CNI plugin into different environments
* `crd-rbac`: Contains the Kubernetes ClusterRoles
* `crds`: Contains the Airlock Microgateway CustomResourceDefinitions
* `deployment`: Contains the Kubernetes manifest files to deploy and run the Airlock Microgateway Operator
* `operator-installation`: Contains a kustomization file to easily deploy `crds`, `crd-rbac` and `deployment` at once
