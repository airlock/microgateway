# Description
The following folder contain the Kubernetes manifest files needed to deploy the Airlock Microgateway.
* `crd-rbac`: Contains the Kubernetes ClusterRoles
* `crds`: Contains the Airlock Microgateway CustomResourceDefinitions
* `deployment`: Contains the Kubernetes manifest files to deploy and run the Airlock Microgateway Operator
* `operator-installation`: Contains a kustomization file to easily deploy all the previously mentioned resources files at once  