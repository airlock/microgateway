# Gateway API conformance of Airlock Microgateway

## Prerequisites
* [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api)
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)


## Deploy Airlock Microgateway Operator

1. Install CRDs and Operator:

    ```console
    # Create namespace
    kubectl create namespace airlock-microgateway-system

    # Install the Operator
    helm install airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.1.0-alpha1' \
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


