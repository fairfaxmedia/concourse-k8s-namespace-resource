#!/bin/bash

payload="$(mktemp "$TMPDIR/k8s-resource-request.XXXXXX")"
cat > "$payload" <&0

export payload

TEMPDIR=$(mktemp -d)
# shellcheck disable=SC2064
trap "rm -rf ${TEMPDIR}" EXIT

DEBUG=$(jq -r .source.debug < "$payload")
[[ "$DEBUG" == "true" ]] && {
    echo "Enabling debug mode.";
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -x;
}

cd "$1" || exit

# shellcheck disable=SC2089
GET_ANNOTATIONS='if .metadata.annotations then .metadata.annotations else [] end | with_entries(select(.key|test("kubernetes.io/")|not)) | with_entries(select(.key|test("k8s.io/")|not)) | to_entries? | map([.key, .value]|join("=")) | join(", ")'
# shellcheck disable=SC2089
GET_LABELS='.metadata.labels | to_entries? | map([.key, .value]|join("=")) | join(", ")'
# shellcheck disable=SC2090
export GET_ANNOTATIONS GET_LABELS

mkdir -p "$TEMPDIR"

KUBE_URL=$(jq -r .source.cluster_url < "$payload")
NAMESPACE=$(jq -r '.source.namespace // ""' < "$payload")
KUBECTL="/usr/local/bin/kubectl --server=$KUBE_URL"

# configure SSL Certs if available
if [[ "$KUBE_URL" =~ https.* ]]; then
    KUBE_CA=$(jq -r .source.cluster_ca < "$payload")
    KUBE_KEY=$(jq -r .source.admin_key < "$payload")
    KUBE_CERT=$(jq -r .source.admin_cert < "$payload")
    CA_PATH="${TEMPDIR}/ca.pem"
    KEY_PATH="${TEMPDIR}/key.pem"
    CERT_PATH="${TEMPDIR}/cert.pem"

    echo "$KUBE_CA" | base64 -d > "$CA_PATH"
    echo "$KUBE_KEY" | base64 -d > "$KEY_PATH"
    echo "$KUBE_CERT" | base64 -d > "$CERT_PATH"

    KUBECTL="$KUBECTL --certificate-authority=$CA_PATH --client-key=$KEY_PATH --client-certificate=$CERT_PATH"
fi

export KUBECTL NAMESPACE
