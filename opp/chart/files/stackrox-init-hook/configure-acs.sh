#!/bin/bash

set -Eeuo pipefail

mkdir -p /tmp/bin
curl -sfLo /tmp/bin/roxctl  https://mirror.openshift.com/pub/rhacs/assets/4.0.0/bin/Linux/roxctl
chmod 755 /tmp/bin/roxctl
curl -sLo /tmp/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 755 /tmp/bin/jq
export PATH="/tmp/bin:$PATH"

echo "========================================================================"
echo " Connecting to Red Hat ACS"
echo "========================================================================"
echo

export ROX_CENTRAL_ADDRESS="$(oc get route central -n stackrox -o go-template='{{.spec.host}}'):443"
while ! curl -sfko /dev/null "https://$ROX_CENTRAL_ADDRESS/"; do
    echo "Red Hat ACS not ready..."
    sleep 5
    
    # There is a risk the central's route to be created after this script started
    # so we need to periodically refresh it
    export ROX_CENTRAL_ADDRESS="$(oc get route central -n stackrox -o go-template='{{.spec.host}}'):443"
done
export ROX_CENTRAL_HOSTNAME="$ROX_CENTRAL_ADDRESS"

echo "========================================================================"
echo " Retrieving an API Token for Red Hat ACS"
echo "========================================================================"
echo
if ! oc get secret stackrox-api-token -n stackrox &>/dev/null; then
    POLICY_JSON='{ "name": "init-token", "role":"Admin"}'
    APIURL="https://$ROX_CENTRAL_ADDRESS/v1/apitokens/generate"
    export ROX_API_TOKEN=$(curl -s -k -u admin:$ROX_ADMIN_PASSWORD -H 'Content-Type: application/json' -X POST -d "$POLICY_JSON" "$APIURL" | jq -r '.token')
    oc create secret generic stackrox-api-token -n stackrox --from-literal=token="$ROX_API_TOKEN"
else
    export ROX_API_TOKEN="$(oc get secret stackrox-api-token -n stackrox -o go-template --template='{{.data.token|base64decode}}')"
fi

echo "========================================================================"
echo " Generating the Cluster Init Bundle"
echo "========================================================================"
echo

if ! oc get secret admission-control-tls -n stackrox &>/dev/null; then
    roxctl -e "$ROX_CENTRAL_ADDRESS" central init-bundles generate local-cluster --output-secrets /tmp/cluster_init_bundle.yaml
    oc apply -f /tmp/cluster_init_bundle.yaml -n stackrox
fi

exit 0