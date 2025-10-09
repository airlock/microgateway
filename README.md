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
* Kubernetes native integration with sidecar injection and Gateway API support
* Reverse proxy functionality with request routing rules, TLS termination and remote IP extraction
* Using native Envoy HTTP filters like Lua scripting, RBAC, ext_authz, JWT authentication
* Content security filters for protecting against known attacks (OWASP Top 10)
* Access control using OpenID Connect to allow only authenticated users to access the protected services
* API security features like JSON parsing, OpenAPI specification enforcement or GraphQL schema validation

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)**.
## Labs
We offer a growing number of [Airlock Microgateway labs](https://airlock.instruqt.com/pages/airlock-microgateway-labs) that are designed to be easy-to-follow tutorials. All labs are fully guided and cover aspects of Airlock Microgateway from installation to configuration in a preconfigured cloud-based Kubernetes environment.

[![Airlock Microgateway labs](https://raw.githubusercontent.com/airlock/microgateway/main/media/airlock-microgateway-instruqt-tracks.gif)](https://airlock.instruqt.com/pages/airlock-microgateway-labs)

Learn the basics and expand existing knowledge without any administration effort in a secure environment.

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000059)
* [System Architecture](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137)
* [Installation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/index/1659430054787.html)
* [GitHub](https://github.com/airlock/microgateway)

# Quick start guide


The instructions below provide a quick start guide for Gateway API. Detailed information on the installation are provided in the **[manual](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)**.

## Prerequisites
* [Airlock Microgateway License](#obtain-airlock-microgateway-license)
* [cert-manager](https://cert-manager.io/)
* [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api)
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)

In order to use Airlock Microgateway you need a license and the cert-manager. You may either request a community license free of charge or purchase a premium license.
For an easy start in non-production environments, you may deploy the same cert-manager we are using internally for testing.

### Obtain Airlock Microgateway License
1. Either request a community or premium license
   * Community license: [airlock.com/microgateway-community](https://airlock.com/en/microgateway-community)
   * Premium license: [airlock.com/microgateway-premium](https://airlock.com/en/microgateway-premium)
2. Check your inbox and save the license file microgateway-license.txt locally.

> See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056) to choose the right license type.

### Deploy cert-manager
```console
helm install cert-manager \
  oci://quay.io/jetstack/charts/cert-manager \
  --version 'v1.18.2' \
  --namespace cert-manager \
  --create-namespace \
  --wait \
  --set crds.enabled=true
```

### Deploy Kubernetes Gateway API CRDs

```console
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
```

## Deploy Airlock Microgateway Operator

> This guide assumes a microgateway-license.txt file is present in the working directory.

1. Install CRDs and Operator.
   ```console
   # Create namespace
   kubectl create namespace airlock-microgateway-system

   # Install License
   kubectl create secret generic airlock-microgateway-license \
     -n airlock-microgateway-system \
     --from-file=microgateway-license.txt

   # Install Operator (CRDs are included via the standard Helm 3 mechanism, i.e. Helm will handle initial installation but not upgrades)
   helm install airlock-microgateway \
     oci://quay.io/airlockcharts/microgateway \
     --version '4.7.2' \
     -n airlock-microgateway-system \
     --wait \
     --set operator.sidecarGateway.enabled=false \
     --set operator.gatewayAPI.enabled=true
   ```

2. Verify the correctness of the installation (Recommended).
   ```console
   helm upgrade airlock-microgateway \
     oci://quay.io/airlockcharts/microgateway \
     --version '4.7.2' \
     -n airlock-microgateway-system \
     --set tests.enabled=true \
     --reuse-values

   helm test airlock-microgateway -n airlock-microgateway-system --logs

   helm upgrade airlock-microgateway \
     oci://quay.io/airlockcharts/microgateway \
     --version '4.7.2' \
     -n airlock-microgateway-system \
     --set tests.enabled=false \
     --reuse-values
   ```

### Upgrading CRDs

The `helm install/upgrade` command currently does not support upgrading CRDs that already exist in the cluster.
CRDs should instead be manually upgraded before upgrading the Operator itself via the following command:
```console
kubectl apply -k https://github.com/airlock/microgateway/deploy/charts/airlock-microgateway/crds/?ref=4.7.2 \
  --server-side \
  --force-conflicts
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
