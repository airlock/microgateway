# Description
Airlock Microgateway can be used together with [kyverno](https://kyverno.io/).

For an easy start in non-production environments, you may deploy the same kyverno operator we are using internally for testing.

```
kubectl apply --server-side=true -k https://github.com/airlock/microgateway/examples/utilities/kyverno
```

The `--server-side` flag is required in order to overcome the annotation limit, which is exceeded with the `kubectl.kubernetes.io/last-applied-configuration`. One could also first use `kubectl create` and then `kubectl apply` for each subsequent change.