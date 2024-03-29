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
* [Airlock Microgateway License](#obtain-airlock-microgateway-license)
* [cert-manager](https://cert-manager.io/)

In order to use Airlock Microgateway you need a license and the cert-manager. You may either request a community license free of charge or purchase a premium license.
For an easy start in non-production environments, you may deploy the same cert-manager we are using internally for testing.
### Obtain Airlock Microgateway License
1. Either request a community or premium license
   * Community license: [airlock.com/microgateway-community](https://airlock.com/en/microgateway-community)
   * Premium license: [airlock.com/microgateway-premium](https://airlock.com/en/microgateway-premium)
2. Check your inbox and save the license file microgateway-license.txt locally.

> See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/#data/1675772882054.html) to choose the right license type.
### Deploy cert-manager
```
kubectl apply -k https://github.com/airlock/microgateway/examples/utilities/cert-manager/
```

Wait for the cert-manager to be up and running
```
kubectl -n cert-manager wait --for=condition=ready --timeout=600s pod -l app.kubernetes.io/instance=cert-manager
```

## Deploy Airlock Microgateway CNI
Install the CNI DaemonSet and required RBAC manifests with kustomize:

```
kubectl kustomize --enable-helm https://github.com/airlock/microgateway/deploy/cni/<environment> | kubectl apply -f -
```

Consult our [documentation](https://docs.airlock.com/microgateway/latest/#data/1660804708637.html) to verify the installation or to see other installation methods. 

### OpenShift

- Use the preset environment `openshift` when installing the CNI plugin
- It is recommended to install the CNI plugin into the namespace `openshift-operators` instead of `kube-system`
- **Important**: All pods which should be protected by Airlock Microgateway must explicitly reference the Airlock Microgateway CNI NetworkAttachmentDefinition via the annotation `k8s.v1.cni.cncf.io/networks` (see [documentation](https://docs.airlock.com/microgateway/latest/#data/1658483168033.html) for details).

## Deploy Airlock Microgateway
Install the Custom Resource Definitions, the CRD RBAC manifests and the deployment of the Airlock Microgateway Operator.
```
kubectl apply -k https://github.com/airlock/microgateway/deploy/crds/
kubectl apply -k https://github.com/airlock/microgateway/deploy/crd-rbac/
kubectl apply -k https://github.com/airlock/microgateway/deploy/deployment/
```

Wait for the airlock-microgateway-operator deployment to be ready
```
kubectl -n airlock-microgateway-system wait --for=condition=Available deployments --all --timeout=3m
```

> The minimum supported Kustomize version is [v4.5.3](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv4.5.3).

## Deploy Airlock Microgateway License
Create the required secret from the license file that you created in the prerequisite step.
```
kubectl -n airlock-microgateway-system create secret generic airlock-microgateway-license 
--from-file=microgateway-license.txt=<my-local-microgateway-license.txt>
```

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