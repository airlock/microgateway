# Description
There are different tools available to enforce policies for Kubernetes resources. The most famous ones are Open Policy Agent Gatekeeper, Kyverno or Kubewarden. They allow enforcing constraints on Kubernetes resources which includes the Microgateway CRDs.

Basically, the mentioned tools do the same but in detail, they differ in their policy language, Kubernetes-native integration, possibility to use outside Kubernetes, and integration in CI/CD pipeline. This is why you should check which of them suits best for you and whether you use already one of them.

## Examples
### Prerequisites
First install the Kyverno operator:
```
kubectl apply --server-side=true -k https://github.com/airlock/microgateway/examples/utilities/kyverno/
```

Apply the Kyverno policy:
```
kubectl apply -k https://github.com/airlock/microgateway/examples/configurations/policy
```


### Allowed Example
The following example shows a policy with Kyverno which allows secure deny rules settings.

```
kubectl apply -k https://github.com/airlock/microgateway/examples/configurations/policy/allowed
```

Output
```
denyrules.microgateway.airlock.com/denyrule1-ok created
denyrules.microgateway.airlock.com/denyrule2-ok created
```

### Denied Example
This following example shows a policy with Kyverno which denies insecure deny rules settings.

```
kubectl apply -k https://github.com/airlock/microgateway/examples/configurations/policy/denied
```

Output
```
Error from server: error when creating "https://github.com/airlock/microgateway/examples/configurations/policy/denied/denyrules-1.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource DenyRules/default/denyrule1-nok was blocked due to the following policies

disallow-insecure-denyrules:
  disallow-insecure-threatHandlingMode: 'DenyRules with ''threatHandlingMode'' other
    than ''Block'' is not allowed. '

Error from server: error when creating "https://github.com/airlock/microgateway/examples/configurations/policy/denied/denyrules-2.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource DenyRules/default/denyrule2-nok was blocked due to the following policies

disallow-insecure-denyrules:
  disallow-denyRules-with-insecure-security-level: 'DenyRules with ''level'' other
    than ''Standard'' or ''Strict'' is not allowed. '

```

For detailed information consult the [documentation](https://docs.airlock.com/microgateway/nightly/#data/1668421866273.html).