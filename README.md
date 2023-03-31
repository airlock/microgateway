# Airlock Microgateway

Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.

## Documentation

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or follow one of these links:
* [Getting Started](https://docs.airlock.com/microgateway/latest/#data/1660804708742.html)
* [System Architecture](https://docs.airlock.com/microgateway/latest/#data/1660804709650.html)
* [Installation](https://docs.airlock.com/microgateway/latest/#data/1660804708637.html)

## What is Airlock Microgateway?

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. The Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance and can be used in Kubernetes environments. Airlock Microgateway enables you to protect your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.

More information: **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**

### Features
* Kubernetes native integration with its Operator, Custom Resource Definitions, hot-reload, automatic sidecar injection.
* Reverse proxy functionality with request routing rules, TLS termination and remote IP extraction
* Using native Envoy HTTP filters like Lua scripting, RBAC, ext_authz, JWT authentication
* Content security filters for protecting against known attacks (OWASP Top 10)
* Access control to allow only authenticated users to access the protected services
* API security features like JSON parsing or OpenAPI specification enforcement

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/#data/1675772882054.html)**.

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
kubectl -n airlock-microgateway-system wait --for=condition=Available deployments.app/airlock-microgateway-operator-controller-manager --timeout=2m
```

> The minimum supported Kustomize version is [v4.5.3](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv4.5.3).


## How to get help

### Community edition
For the community edition, check our **[Airlock community forum](https://forum.airlock.com/)** for FAQs or register to post your question.

### Premium edition
If you have a paid license, please follow the [premium support process](https://techzone.ergon.ch/support-process).

## License
View the [detailed license terms](https://www.airlock.com/en/airlock-license) for the software contained in this image.
* Decompiling or reverse engineering is not permitted.
* Using any of the deny rules or parts of these filter patterns outside of the image is not permitted.

![Airlock Logo](https://www.airlock.com/fileadmin/content/upload/Airlock_Logo_Docker_Hub_Microgateway_Readme.png)