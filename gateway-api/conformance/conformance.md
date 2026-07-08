# Gateway API conformance of Airlock Microgateway

## Prerequisites
* git
* go (recent version)
* kubectl

## Running conformance tests

1. Run the conformance test script (needs internet connectivity as it will install certain tools from source and deploy a kind cluster with Airlock Microgateway and Gateway API CRDs)
```console
# Usage: ./run_conformance.sh <airlock_microgateway_helm_chart_version> <gateway_api_version> <gateway_api_channel>
./run_conformance.sh 5.1.2 v1.6.0 experimental
```

2. When the tests finish, the report is saved to `./<gateway_api_channel>-<airlock_microgateway_helm_chart_version>-default-report.yaml`
