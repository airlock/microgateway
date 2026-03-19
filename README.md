<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_Negative.svg" width="400">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled.svg" width="400">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled.svg" width="400">
</picture>

[![Release](https://img.shields.io/badge/Release-v5.0.0-6bba62)](https://github.com/airlock/microgateway/releases/tag/5.0.0)
[![Gateway API Conformance](https://img.shields.io/badge/Gateway%20API%20Conformance-v1.5.1-6bba62?logo=kubernetes&logoColor=white)](https://github.com/kubernetes-sigs/gateway-api/blob/main/conformance/reports/v1.5.1/airlock-microgateway)
[![GitHub](https://img.shields.io/badge/GitHub-Published-6bba62?logo=github&logoColor=white)](https://github.com/airlock/microgateway/releases/tag/5.0.0)
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

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)**.
## Labs
We offer a growing number of [Airlock Microgateway labs](https://airlock.instruqt.com/pages/airlock-microgateway-labs) that are designed to be easy-to-follow tutorials. All labs are fully guided and cover aspects of Airlock Microgateway from installation to configuration in a preconfigured cloud-based Kubernetes environment.

Learn the basics and expand existing knowledge without any administration effort in a secure environment.

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000059)
* [System Architecture](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137)
* [Installation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/index/1659430054787.html)


# Quick start guide

The instructions below provide a quick start guide. Detailed information on the installation are provided in the **[manual](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)**.

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

### Deploy Kubernetes Gateway API CRDs

```console
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
```

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

    # Install Operator (CRDs are included via the standard Helm 3 mechanism, i.e. Helm will handle initial installation but not upgrades)
    helm install airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.0.0' \
      -n airlock-microgateway-system \
      --wait
    ```

2. Verify that the Operator started successfully:

    ```console
    kubectl -n airlock-microgateway-system wait \
      --for=condition=Available deployments --all --timeout=3m
    ```

3. Verify the correctness of the installation (Recommended):

    ```console
    helm upgrade airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.0.0' \
      -n airlock-microgateway-system \
      --set tests.enabled=true \
      --reuse-values

    helm test airlock-microgateway -n airlock-microgateway-system --logs

    helm upgrade airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.0.0' \
      -n airlock-microgateway-system \
      --set tests.enabled=false \
      --reuse-values
    ```

### Upgrading CRDs

The `helm install/upgrade` command currently does not support upgrading CRDs that already exist in the cluster.
CRDs should instead be manually upgraded before upgrading the Operator itself via the following command:

```console
kubectl apply -k https://github.com/airlock/microgateway/deploy/charts/airlock-microgateway/crds/?ref=5.0.0 \
  --server-side \
  --force-conflicts
```

**Note**: Certain GitOps solutions such as e.g. Argo CD or Flux CD have their own mechanisms for automatically upgrading CRDs included with Helm charts.

## What’s next
After installing the Airlock Microgateway Operator, the next steps describe how to deploy and configure a Gateway in your cluster and how to implement common scenarios.

* [Gateway deployment](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000147)

    Deploy the gateway either as an Ingress or as an in-cluster Gateway.

* [Session handling](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000148)

    Enable session handling to persist session information and correlate requests with a session ID. This is a prerequisite for OIDC-based authentication.

* [Use cases](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000146)

    Learn how to use Airlock Microgateway for other typical scenarios such as request routing, request filtering or authentication enforcement.

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
