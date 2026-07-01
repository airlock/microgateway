#!/bin/sh
set -eu

usage() {
	echo "Usage: $0 <airlock_microgateway_helm_chart_version> <gateway_api_version> <gateway_api_channel> [-v] [--parallel <concurrency_limit>] [--use-existing-cloud-provider-kind]"
	exit 1
}

airlock_microgateway_helm_chart_version=${1?$(usage)}
gateway_api_version=${2?$(usage)}
gateway_api_channel=${3?$(usage)}
shift 3

cluster_channel=
case "${gateway_api_channel}" in
	standard) cluster_channel=std ;;
	experimental) cluster_channel=exp ;;
	*)
		echo "channel must be either 'standard' or 'experimental'"
		exit 1
		;;
esac

verbose_flag=
existing_cpk=false
parallel_flag=
while [ $# -gt 0 ]; do
	case "$1" in
		-v)
			verbose_flag=-v
			shift
			;;
		--parallel)
			parallel_flag=-parallel=${2?$(usage)}
			shift 2
			;;
		--use-existing-cloud-provider-kind)
			existing_cpk=true
			shift
			;;
		*)
			usage
			;;
	esac
done

operator_helm_chart=${OPERATOR_HELM_CHART:-oci://quay.io/airlockcharts/microgateway}
kind_config=${KIND_CONFIG:-"$(cat << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
EOF
)"}

cloud_provider_kind_version=v0.11.0
gotestsum_version=v1.13.0
helm_version=v4.2.2
kind_version=v0.32.0

working_dir=$(pwd)
gwapi_dir=${working_dir}/.gateway-api-${gateway_api_version}-${gateway_api_channel}
cluster_name=$(echo "gwapi-${gateway_api_version}-${cluster_channel}-mgw-$(echo "${airlock_microgateway_helm_chart_version}" | tr -d ^)" | cut -c1-49)

cleanup() {
	status=$?
	trap - EXIT TERM INT
	echo "# Cleaning up..."

	if [ -n "${cpk_pid:-}" ] && kill -0 "${cpk_pid}" 2>/dev/null; then
		echo "## Stopping cloud-provider-kind..."
		kill "${cpk_pid}" 2>/dev/null || true
		wait "${cpk_pid}" 2>/dev/null || true
	fi

	echo "## Deleting kind cluster..."
	if [ -f "${GOBIN}/kind" ]; then
		"${GOBIN}/kind" delete cluster --name "${cluster_name}" || true
	fi

	echo "## Removing '${gwapi_dir}'..."
	if [ -d "${gwapi_dir}" ]; then
		rm -rf "${gwapi_dir}"
	fi

	exit "${status}"
}
trap 'cleanup' EXIT TERM INT

export GOBIN="${gwapi_dir}"
export KUBECONFIG="${gwapi_dir}/.kube/config"

echo "# 1. Cloning Gateway API"
gateway_api_ref=${gateway_api_version}
supported_features_flag=
case "${gateway_api_version}" in
	v1.2.*|v1.3.*)
		supported_features_flag=--supported-features=Gateway,GatewayHTTPListenerIsolation,GatewayInfrastructurePropagation,GatewayPort8080,HTTPRoute,HTTPRouteBackendProtocolH2C,HTTPRouteBackendProtocolWebSocket,HTTPRouteBackendTimeout,HTTPRouteDestinationPortMatching,HTTPRouteHostRewrite,HTTPRouteMethodMatching,HTTPRouteParentRefPort,HTTPRoutePathRedirect,HTTPRoutePathRewrite,HTTPRoutePortRedirect,HTTPRouteQueryParamMatching,HTTPRouteRequestTimeout,HTTPRouteResponseHeaderModification,HTTPRouteSchemeRedirect
		;;
	v1.5.*)
		# <=v1.5.1 release tag has broken conformance tests, use release branch instead
		gateway_api_ref=release-1.5
		;;
esac

git clone -q --depth 1 -c advice.detachedHead=false --branch "${gateway_api_ref}" https://github.com/kubernetes-sigs/gateway-api.git "${gwapi_dir}"

echo "# 2. Installing prerequisites"
go install sigs.k8s.io/kind@${kind_version}
go install helm.sh/helm/v4/cmd/helm@${helm_version}
go install gotest.tools/gotestsum@${gotestsum_version}
[ "${existing_cpk}" = 'true' ] || go install sigs.k8s.io/cloud-provider-kind@${cloud_provider_kind_version}

echo "# 3. Create Cluster"
echo "${kind_config}" | "${GOBIN}/kind" create cluster --name "${cluster_name}" --wait 120s --config -
if [ "${existing_cpk}" = 'false' ]; then
	"${GOBIN}/cloud-provider-kind" --gateway-channel=disabled --enable-default-ingress=false -v0 >/dev/null 2>&1 &
	cpk_pid="$!"
fi

echo "# 4. Deploy Gateway API"
kubectl apply --server-side -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${gateway_api_version}/${gateway_api_channel}-install.yaml"

echo "# 5. Deploy Airlock Microgateway"
"${GOBIN}/helm" install airlock-microgateway "${operator_helm_chart}" --version "${airlock_microgateway_helm_chart_version}" --wait

echo "# 6. Run conformance tests"
cd "${gwapi_dir}"
cat<<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: gateway-conformance
spec:
  controllerName: microgateway.airlock.com/gatewayclass-controller
EOF

"${GOBIN}/gotestsum" --format testname -- -json -timeout 30m ${verbose_flag} ${parallel_flag} ./conformance -run TestConformance -args \
  --organization=airlock --project=microgateway --url="https://github.com/airlock/microgateway" --version="${airlock_microgateway_helm_chart_version}" --contact="https://www.airlock.com/en/contact" \
  --conformance-profiles=GATEWAY-HTTP \
  ${supported_features_flag} \
  --report-output="${working_dir}/${gateway_api_channel}-${airlock_microgateway_helm_chart_version}-default-report.yaml"
