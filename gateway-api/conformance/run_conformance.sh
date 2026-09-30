#!/bin/sh
set -eu

usage() {
	echo "Usage: $0 <airlock_microgateway_helm_chart_version> <gateway_api_version> <gateway_api_channel> [-v] [--parallel <concurrency_limit>]"
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
		*)
			usage
			;;
	esac
done

github_manifest_host=${GITHUB_MANIFEST_HOST:-github.com}
operator_helm_chart=${OPERATOR_HELM_CHART:-oci://quay.io/airlockcharts/microgateway}
kind_config=${KIND_CONFIG:-"$(cat << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
EOF
)"}

metallb_version=v0.16.0
gotestsum_version=v1.13.0
helm_version=v4.3.0
kind_version=v0.33.0

working_dir=$(pwd)
gwapi_dir=${working_dir}/.gateway-api-${gateway_api_version}-${gateway_api_channel}
cluster_name=$(echo "gwapi-${gateway_api_version}-${cluster_channel}-mgw-$(echo "${airlock_microgateway_helm_chart_version}" | tr -d ^)" | cut -c1-49)

cleanup() {
	status=$?
	trap - EXIT TERM INT
	echo "# Cleaning up..."

	echo "## Deleting kind cluster..."
	if [ -f "${GOBIN}/kind" ]; then
		"${GOBIN}/kind" delete cluster --name "${cluster_name}" || true
		docker network rm "${cluster_name}" || true
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
case "${gateway_api_version}" in
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

echo "# 3. Create Cluster"
docker network create "${cluster_name}"
echo "${kind_config}" | KIND_EXPERIMENTAL_DOCKER_NETWORK="${cluster_name}" "${GOBIN}/kind" create cluster --name "${cluster_name}" --wait 120s --config -

kubectl apply -f "https://${github_manifest_host}/metallb/metallb/raw/${metallb_version}/config/manifests/metallb-native.yaml"
kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=120s

docker_subnet=$(docker network inspect --format '{{range .IPAM.Config}}{{if eq (len (split .Subnet ":")) 1}}{{.Subnet}}{{println}}{{end}}{{end}}' "${cluster_name}" 2>/dev/null | head -1)
if [ -z "${docker_subnet}" ]; then
		echo "failed to retrieve docker network" >&2; exit 1
fi
ip_address_prefix=$(echo "${docker_subnet}" | awk -F. '{print $1"."$2"."$3}')

metallb_config=$(cat << EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: dynamic
  namespace: metallb-system
spec:
  autoAssign: true
  addresses:
    - ${ip_address_prefix}.20-${ip_address_prefix}.199
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: static
  namespace: metallb-system
spec:
  autoAssign: false
  addresses:
    - ${ip_address_prefix}.200/32
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: kind
  namespace: metallb-system
spec:
  ipAddressPools:
    - dynamic
    - static
EOF
)
attempt=0
until echo "${metallb_config}" | kubectl apply -f -; do
	attempt=$((attempt + 1))
	if [ "${attempt}" -ge 30 ]; then
		echo "failed to apply MetalLB configuration" >&2
		exit 1
	fi
	sleep 2
done

echo "# 4. Deploy Gateway API"
kubectl apply --server-side -f "https://${github_manifest_host}/kubernetes-sigs/gateway-api/releases/download/${gateway_api_version}/${gateway_api_channel}-install.yaml"

echo "# 5. Deploy Airlock Microgateway"
"${GOBIN}/helm" install airlock-microgateway "${operator_helm_chart}" --version "${airlock_microgateway_helm_chart_version}" --namespace airlock-microgateway-system --create-namespace --wait

echo "# 6. Run conformance tests"
address_flags=
supported_features_flag=
case "${gateway_api_version}" in
	v1.2.*|v1.3.*)
		supported_features_flag=--supported-features=Gateway,GatewayHTTPListenerIsolation,GatewayInfrastructurePropagation,GatewayPort8080,HTTPRoute,HTTPRouteBackendProtocolH2C,HTTPRouteBackendProtocolWebSocket,HTTPRouteBackendTimeout,HTTPRouteDestinationPortMatching,HTTPRouteHostRewrite,HTTPRouteMethodMatching,HTTPRouteParentRefPort,HTTPRoutePathRedirect,HTTPRoutePathRewrite,HTTPRoutePortRedirect,HTTPRouteQueryParamMatching,HTTPRouteRequestTimeout,HTTPRouteResponseHeaderModification,HTTPRouteSchemeRedirect
		;;
	v1.4.*)
		;;
	*)
		address_flags="--usable-address=${ip_address_prefix}.200 --unusable-address=8.8.8.8"
		;;
esac

cd "${gwapi_dir}"
"${GOBIN}/gotestsum" --format testname -- -json -timeout 30m ${verbose_flag} ${parallel_flag} ./conformance -run TestConformance -args \
  --gateway-class=airlock-microgateway \
  --organization=airlock --project=microgateway --url="https://github.com/airlock/microgateway" --version="${airlock_microgateway_helm_chart_version}" --contact="https://www.airlock.com/en/contact" \
  --conformance-profiles=GATEWAY-HTTP \
  ${address_flags} \
  ${supported_features_flag} \
  --report-output="${working_dir}/${gateway_api_channel}-${airlock_microgateway_helm_chart_version}-default-report.yaml"
