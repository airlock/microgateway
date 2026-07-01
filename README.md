<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_Negative.svg" width="400">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled.svg" width="400">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled.svg" width="400">
</picture>

[![Release](https://img.shields.io/badge/Release-v5.1.0-6bba62)](https://github.com/airlock/microgateway/releases/tag/5.1.0)
[![Gateway API Conformance](https://img.shields.io/badge/Gateway%20API%20Conformance-v1.6.0-6bba62?logo=kubernetes&logoColor=white)](https://github.com/kubernetes-sigs/gateway-api/blob/main/conformance/reports/v1.6.0/airlock-microgateway)
[![GitHub](https://img.shields.io/badge/GitHub-Published-6bba62?logo=github&logoColor=white)](https://github.com/airlock/microgateway/releases/tag/5.1.0)
[![Artifact Hub](https://img.shields.io/badge/Artifact%20Hub-Published-6bba62?logo=artifacthub&logoColor=white)](https://artifacthub.io/packages/helm/airlock-microgateway/microgateway)
[![OpenShift Certified](https://img.shields.io/badge/OpenShift%20Certification-Passed-6bba62?logo=redhatopenshift)](https://catalog.redhat.com/en/software/container-stacks/detail/67177f927cfedb209761e48f)

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance, optimized for Kubernetes environments. Airlock Microgateway protects your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.

### Features
* Kubernetes native integration with Gateway API
* Comprehensive set of security features, including deny rules to protect against known attacks (OWASP Top 10), header filtering, JSON parsing, OpenAPI specification enforcement, GraphQL schema validation, and antivirus scanning with ICAP
* Identity aware proxy which makes it possible to enforce authentication using client certificate based authentication, JWT authentication or OIDC with step-up authentication to realize multi factor authentication (MFA). Provides OAuth 2.0 Token Introspection and Token Exchange for continuous validation and secure delegation across services
* Reverse proxy functionality with request routing rules, TLS termination, and remote IP extraction
* Easy-to-use Grafana dashboards which provide valuable insights in allowed and blocked traffic and other metrics

A valid license is required unless Airlock Microgateway is used in the Community Edition.
For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)**.

# Quick start guide

The instructions below provide a quick start guide. Detailed information on the installation are provided in the **[manual](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)**.

## Prerequisites
* [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api)
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)


### Deploy Kubernetes Gateway API CRDs

```console
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.0/standard-install.yaml
```

## Deploy Airlock Microgateway Operator

1. Install CRDs and Operator:

    ```console
    # Create namespace
    kubectl create namespace airlock-microgateway-system

    # Install the Operator (CRDs are included via the standard Helm 3 mechanism, i.e. Helm will handle initial installation but not upgrades)
    helm install airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.1.0' \
      -n airlock-microgateway-system \
      --wait
    ```

2. Verify the correctness of the installation (Recommended):

    ```console
    helm upgrade airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.1.0' \
      -n airlock-microgateway-system \
      --set tests.enabled=true \
      --reuse-values

    helm test airlock-microgateway -n airlock-microgateway-system --logs

    helm upgrade airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.1.0' \
      -n airlock-microgateway-system \
      --set tests.enabled=false \
      --reuse-values
    ```


## What’s next

After installing the Airlock Microgateway Operator, the various [Configuration Guides](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000146) describe how to deploy and configure a Gateway in your cluster and how to implement common scenarios.
> Several features require a license. See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056) to choose the right license type.

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
