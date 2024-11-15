# Airlock Microgateway
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/airlock-microgateway)](https://artifacthub.io/packages/helm/airlock-microgateway/microgateway)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/airlock-microgateway-cni)](https://artifacthub.io/packages/helm/airlock-microgateway-cni/microgateway-cni)

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight_Negative.svg">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg" align="right" width="250">
</picture>

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance, optimized for Kubernetes environments. Airlock Microgateway protects your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.

### Features
* Kubernetes native integration with its Operator, Custom Resource Definitions, hot-reload, automatic sidecar injection.
* Reverse proxy functionality with request routing rules, TLS termination and remote IP extraction
* Using native Envoy HTTP filters like Lua scripting, RBAC, ext_authz, JWT authentication
* Content security filters for protecting against known attacks (OWASP Top 10)
* Access control to allow only authenticated users to access the protected services
* API security features like JSON parsing or OpenAPI specification enforcement

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/#data/1675772882054.html)**.
## Labs
We offer a growing number of [Airlock Microgateway labs](https://play.instruqt.com/airlock/invite/hyi9fy4b4jzc?icp_referrer=github.com) that are designed to be easy-to-follow tutorials. All labs are fully guided and cover aspects of Airlock Microgateway from installation to configuration in a preconfigured cloud-based Kubernetes environment.

[![Airlock Microgateway labs](https://raw.githubusercontent.com/airlock/microgateway/main/media/airlock-microgateway-instruqt-tracks.gif)](https://play.instruqt.com/airlock/invite/hyi9fy4b4jzc?icp_referrer=github.com)

Learn the basics and expand existing knowledge without any administration effort in a secure environment.

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/#data/1660804708742.html)
* [System Architecture](https://docs.airlock.com/microgateway/latest/#data/1660804709650.html)
* [Installation](https://docs.airlock.com/microgateway/latest/#data/1660804708637.html)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/#data/1659430054787.html)
* [GitHub](https://github.com/airlock/microgateway)

# Quick start guide

The instructions below provide a quick start guide. Detailed information are provided in the **[manual](https://docs.airlock.com/microgateway/latest/)**.

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
```bash
# Install cert-manager
kubectl apply -k https://github.com/airlock/microgateway/examples/utilities/cert-manager/?ref=4.2.9

# Wait for the cert-manager to be up and running
kubectl -n cert-manager wait --for=condition=ready --timeout=600s pod -l app.kubernetes.io/instance=cert-manager
```

## Deploy Airlock Microgateway CNI
1. Install the CNI Plugin with Helm.
   > **Note**: Certain environments such as OpenShift or GKE require non-default configurations when installing the CNI plugin. For the most common setups, values files are provided in the [chart folder](/deploy/charts/airlock-microgateway-cni).
   ```bash
   # Standard setup
   helm install airlock-microgateway-cni -n kube-system oci://quay.io/airlockcharts/microgateway-cni --version '4.2.9'
   kubectl -n kube-system rollout status daemonset -l app.kubernetes.io/instance=airlock-microgateway-cni
   ```
   ```bash
   # GKE setup
   helm install airlock-microgateway-cni -n kube-system oci://quay.io/airlockcharts/microgateway-cni --version '4.2.9' -f https://raw.githubusercontent.com/airlock/microgateway/4.2.9/deploy/charts/airlock-microgateway-cni/gke-values.yaml
   kubectl -n kube-system rollout status daemonset -l app.kubernetes.io/instance=airlock-microgateway-cni
   ```
   ```bash
   # OpenShift setup
   helm install airlock-microgateway-cni -n openshift-operators oci://quay.io/airlockcharts/microgateway-cni --version '4.2.9' -f https://raw.githubusercontent.com/airlock/microgateway/4.2.9/deploy/charts/airlock-microgateway-cni/openshift-values.yaml
   kubectl -n openshift-operators rollout status daemonset -l app.kubernetes.io/instance=airlock-microgateway-cni
   ```
   **Important:** On OpenShift, all pods which should be protected by Airlock Microgateway must explicitly reference the Airlock Microgateway CNI NetworkAttachmentDefinition via the annotation `k8s.v1.cni.cncf.io/networks` (see [documentation](https://docs.airlock.com/microgateway/latest/#data/1658483168033.html) for details).

2. (Recommended) You can verify the correctness of the installation with `helm test`.
   ```bash
   # Standard and GKE setup
   helm upgrade airlock-microgateway-cni -n kube-system --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.2.9'
   helm test airlock-microgateway-cni -n kube-system --logs
   helm upgrade airlock-microgateway-cni -n kube-system --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.2.9'
   ```
   ```bash
   # OpenShift setup
   helm upgrade airlock-microgateway-cni -n openshift-operators --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.2.9'
   helm test airlock-microgateway-cni -n openshift-operators --logs
   helm upgrade airlock-microgateway-cni -n openshift-operators --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.2.9'
   ```

   Consult our [documentation](https://docs.airlock.com/microgateway/latest/#data/1699611533587.html) in case of any installation error.

## Deploy Airlock Microgateway Operator

> This guide assumes a microgateway-license.txt file is present in the working directory.

1. Install CRDs and Operator.
   ```bash
   # Create namespace
   kubectl create namespace airlock-microgateway-system

   # Install License
   kubectl -n airlock-microgateway-system create secret generic airlock-microgateway-license --from-file=microgateway-license.txt

   # Install Operator (CRDs are included via the standard Helm 3 mechanism, i.e. Helm will handle initial installation but not upgrades)
   helm install airlock-microgateway -n airlock-microgateway-system oci://quay.io/airlockcharts/microgateway --version '4.2.9' --wait
   ```

2. (Recommended) You can verify the correctness of the installation with `helm test`.
   ```bash
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.2.9'
   helm test airlock-microgateway -n airlock-microgateway-system --logs
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.2.9'
   ```

### Upgrading CRDs

The `helm install/upgrade` command currently does not support upgrading CRDs that already exist in the cluster.
CRDs should instead be manually upgraded before upgrading the Operator itself via the following command:
```bash
kubectl apply -k https://github.com/airlock/microgateway/deploy/charts/airlock-microgateway/crds/?ref=4.2.9 --server-side --force-conflicts
```

**Note**: Certain GitOps solutions such as e.g. Argo CD or Flux CD have their own mechanisms for automatically upgrading CRDs included with Helm charts.

## Support

### Premium support
If you have a paid license, please follow the [premium support process](https://techzone.ergon.ch/support-process).

### Community support
For the community edition, check our **[Airlock community forum](https://forum.airlock.com/)** for FAQs or register to post your question.

## License
View the [detailed license terms](https://www.airlock.com/en/airlock-license) for the software contained in this image.
* Decompiling or reverse engineering is not permitted.
* Using any of the deny rules or parts of these filter patterns outside of the image is not permitted.


Airlock<sup>&#174;</sup> is a security innovation by [ergon](https://www.ergon.ch/en)

<!-- Airlock SAH Logo (different image for light/dark mode) -->
<a href="https://www.airlock.com/en/secure-access-hub/">
<picture>
    <source media="(prefers-color-scheme: dark)"
        srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Airlock_Logo_Negative.png">
    <source media="(prefers-color-scheme: light)"
        srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Airlock_Logo.png">
    <img alt="Airlock Secure Access Hub" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Airlock_Logo.png" width="150">
</picture>
</a>
