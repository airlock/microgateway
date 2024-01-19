# Description
Airlock Microgateway can be used together with [kyverno](https://kyverno.io/).

For an easy start in non-production environments, you may deploy the same kyverno operator we are using internally for testing.

```
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno --version '3.1.3' -n kyverno --create-namespace --wait -f https://raw.githubusercontent.com/airlock/microgateway/main/examples/utilities/kyverno/values.yaml
```
