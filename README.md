# Airlock Microgateway

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

# Quick start guide

The instructions below provide a quick start guide. Detailed information are provided in the **[manual](https://docs.airlock.com/microgateway/latest/)**.

## Prerequisites

For an easy start in non-production environments, you may deploy the same cert-manager we are using internally for testing.

### Deploy the cert-manager
```
kubectl apply -k https://github.com/airlock/microgateway/examples/utilities/cert-manager/
```

Wait for the cert-manager to be up and running
```
kubectl -n cert-manager wait --for=condition=ready --timeout=600s pod -l app.kubernetes.io/instance=cert-manager
```

## Deploy Airlock Microgateway
Install the Custom Resource Definitions, the CRD RBAC manifests and the deployment of the Airlock Microgateway Operator.
```
kubectl apply -k https://github.com/airlock/microgateway/deploy/crds/
kubectl apply -k https://github.com/airlock/microgateway/deploy/crd-rbac/
kubectl apply -k https://github.com/airlock/microgateway/deploy/deployment/
```

Wait for the airlock-microgateway-operator deployment to be ready
```
kubectl -n airlock-microgateway-system wait --for=condition=Available deployments.app/airlock-microgateway-operator-controller-manager --timeout=3m
```

> The minimum supported Kustomize version is [v4.5.3](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv4.5.3).


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