# Gateway API conformance of Airlock Microgateway

## Prerequisites
* [Airlock Microgateway License](#obtain-airlock-microgateway-license)
* [cert-manager](https://cert-manager.io/)
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)

In order to use Airlock Microgateway you need a license and the cert-manager. You may either request a community license free of charge or purchase a premium license.
For an easy start in non-production environments, you may deploy the same cert-manager we are using internally for testing.
### Obtain Airlock Microgateway License
1. Either request a community or premium license
   * Community license: [airlock.com/microgateway-community](https://airlock.com/en/microgateway-community)
   * Premium license: [airlock.com/microgateway-premium](https://airlock.com/en/microgateway-premium)
2. Check your inbox and save the license file microgateway-license.txt locally.

> See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/#data/1675772882054.html) to choose the right license type.
### Deploy cert-manager
```console
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --version 'v1.16.3' -n cert-manager --create-namespace --set crds.enabled=true --wait
```

## Deploy Airlock Microgateway Operator

> This guide assumes a microgateway-license.txt file is present in the working directory.

1. Install CRDs and Operator.
   ```console
   # Create namespace
   kubectl create namespace airlock-microgateway-system

   # Install License
   kubectl -n airlock-microgateway-system create secret generic airlock-microgateway-license --from-file=microgateway-license.txt

   # Install the operator and activate the Gateway API support.
   helm install -n airlock-microgateway-system airlock-microgateway oci://quay.io/airlockcharts/microgateway --wait --version '4.5.1' --set=operator.gatewayAPI.enabled=true
   ```

2. Verify that the operator started successfully:
   ```console
   kubectl -n airlock-microgateway-system wait --for=condition=Available deployments --all --timeout=3m
   ```

3. Deploy manifests (GatewayClass, ServiceAccount and ClusterRoleBinding) and run Job to generate report
   ```console
   kubectl apply -f manifests/conformance-report.yaml
   ```

4. After running, see the conformance report:
   ```console
   kubectl logs jobs/gateway-conformance-tests -f
   ```

