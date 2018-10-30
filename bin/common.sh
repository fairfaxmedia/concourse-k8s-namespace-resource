#!/bin/bash

payload="$(mktemp "$TMPDIR/k8s-resource-request.XXXXXX")"
cat > "$payload" <&0

export payload

DEBUG=$(jq -r .source.debug < "$payload")
[[ "$DEBUG" == "true" ]] && { 
    echo "Enabling debug mode.";
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -x;
}

cd "$1" || exit

mkdir -p /root/.kube

KUBE_URL=$(jq -r .source.cluster_url < "$payload")
NAMESPACE=$(jq -r '.source.namespace // ""' < "$payload")
KUBECTL="/usr/local/bin/kubectl --server=$KUBE_URL"

# configure SSL Certs if available
if [[ "$KUBE_URL" =~ https.* ]]; then
    KUBE_CA=$(jq -r .source.cluster_ca < "$payload")
    KUBE_KEY=$(jq -r .source.admin_key < "$payload")
    KUBE_CERT=$(jq -r .source.admin_cert < "$payload")
    CA_PATH="/root/.kube/ca.pem"
    KEY_PATH="/root/.kube/key.pem"
    CERT_PATH="/root/.kube/cert.pem"

    echo "$KUBE_CA" | base64 -d > $CA_PATH
    echo "$KUBE_KEY" | base64 -d > $KEY_PATH
    echo "$KUBE_CERT" | base64 -d > $CERT_PATH

    KUBECTL="$KUBECTL --certificate-authority=$CA_PATH --client-key=$KEY_PATH --client-certificate=$CERT_PATH"
fi

export KUBECTL NAMESPACE
