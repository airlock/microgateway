# Description
Airlock Microgateway requires [cert-manager](https://cert-manager.io/).

For an easy start in non-production environments, you may deploy the same cert-manager we are using internally for testing.

```
kubectl apply -k https://github.com/airlock/microgateway/examples/utilities/cert-manager
```