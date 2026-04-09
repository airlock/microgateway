# Gateway API conformance of Airlock Microgateway

## Prerequisites
* [Airlock Microgateway License](#obtain-airlock-microgateway-license)
* [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api)
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)

### Obtain Airlock Microgateway License
1. Either request a community or premium license
   * Community license (free): [airlock.com/microgateway-community](https://airlock.com/en/microgateway-community)
   * Premium license: [airlock.com/microgateway-premium](https://airlock.com/en/microgateway-premium)
2. Check your inbox and save the license file microgateway-license.txt locally.

> See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056) to choose the right license type.

## Deploy Airlock Microgateway Operator

> This guide assumes a microgateway-license.txt file is present in the working directory.

1. Install CRDs and Operator:

    ```console
    # Create namespace
    kubectl create namespace airlock-microgateway-system

    # Install License
    kubectl create secret generic airlock-microgateway-license \
      -n airlock-microgateway-system \
      --from-file=microgateway-license.txt

    # Install the Operator
    helm install airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.0.1' \
      -n airlock-microgateway-system \
      --wait
    ```
2. Deploy manifests (GatewayClass, ServiceAccount and ClusterRoleBinding) and run Job to generate report:

    ```console
    kubectl apply -f manifests/conformance-report.yaml
    ```

3. After running, see the conformance report:

    ```console
    kubectl logs jobs/gateway-conformance-tests -f
    ```


