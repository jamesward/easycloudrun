#!/usr/bin/env bash
#
# Based on: https://cloud.google.com/run/docs/multiple-regions
#

#set -uxo pipefail

export CLOUDSDK_CORE_DISABLE_PROMPTS=1

if [[ -z "${PROJECT_ID}" ]]; then
  echo "PROJECT_ID env var not set"
  exit 1
fi

if [[ -z "${IMAGE_NAME}" ]]; then
  echo "IMAGE_NAME env var not set"
  exit 1
fi

if [[ -z "${DOMAINS}" ]]; then
  echo "DOMAINS env var not set"
  exit 1
fi

# TODO: memory, cpu, env vars, etc

. ./libs/build_id_to_trigger_id.sh

readonly SERVICE_IP=$IMAGE_NAME-ip

gcloud compute addresses describe --global $SERVICE_IP --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud compute addresses create --global $SERVICE_IP --project $PROJECT_ID
  set +e
fi

readonly BACKEND_NAME=$IMAGE_NAME-backend

gcloud compute backend-services describe --global $BACKEND_NAME --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud compute backend-services create --global $BACKEND_NAME --enable-cdn --cache-mode=USE_ORIGIN_HEADERS --project $PROJECT_ID
  set +e
fi

readonly URLMAP_NAME=$IMAGE_NAME-urlmap

gcloud compute url-maps describe --global $URLMAP_NAME --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud compute url-maps create --global $URLMAP_NAME --default-service=$BACKEND_NAME --project $PROJECT_ID
  set +e
fi

readonly CERT_NAME=$IMAGE_NAME-cert

gcloud beta compute ssl-certificates describe $CERT_NAME --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud beta compute ssl-certificates create $CERT_NAME --domains=$DOMAINS --project $PROJECT_ID
  set +e
fi

readonly HTTPS_PROXY_NAME=$IMAGE_NAME-https

gcloud compute target-https-proxies describe $HTTPS_PROXY_NAME --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud compute target-https-proxies create $HTTPS_PROXY_NAME --ssl-certificates=$CERT_NAME --url-map=$URLMAP_NAME --project $PROJECT_ID
  set +e
fi

readonly FORWARDING_RULE_NAME=$IMAGE_NAME-lb

gcloud compute forwarding-rules describe --global $FORWARDING_RULE_NAME --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud compute forwarding-rules create --global $FORWARDING_RULE_NAME --target-https-proxy=$HTTPS_PROXY_NAME --address=$SERVICE_IP --ports=443 --project $PROJECT_ID
  set +e
fi

# http to https redirect

readonly HTTP_URLMAP_NAME=$IMAGE_NAME-httpredirect

gcloud compute url-maps describe --global $HTTP_URLMAP_NAME --project $PROJECT_ID &> /dev/null
if [ $? -ne 0 ]; then
  set -e

  gcloud compute url-maps import --global $HTTP_URLMAP_NAME --source /dev/stdin  --project $PROJECT_ID <<EOF
name: $HTTP_URLMAP_NAME
defaultUrlRedirect:
  redirectResponseCode: MOVED_PERMANENTLY_DEFAULT
  httpsRedirect: True
EOF

  set +e
fi

readonly HTTP_PROXY_NAME=$IMAGE_NAME-http

gcloud compute target-http-proxies describe $HTTP_PROXY_NAME --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud compute target-http-proxies create $HTTP_PROXY_NAME --url-map=$HTTP_URLMAP_NAME --project $PROJECT_ID
  set +e
fi

readonly HTTP_FORWARDING_RULE_NAME=$IMAGE_NAME-httplb

gcloud compute forwarding-rules describe --global $HTTP_FORWARDING_RULE_NAME --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud compute forwarding-rules create --global $HTTP_FORWARDING_RULE_NAME --target-http-proxy=$HTTP_PROXY_NAME --address=$SERVICE_IP --ports=80 --project $PROJECT_ID
  set +e
fi

readonly BACKEND_NEGS=$(gcloud beta compute backend-services describe --global $BACKEND_NAME --project $PROJECT_ID --flatten="backends[]" --format="value(backends.group.basename())")

readonly REGIONS=$(gcloud run regions list --project $PROJECT_ID --format="value(locationId)")

#readonly REGIONS="us-central1 us-west1"

function deploy() {
  local REGION=$1

  set -e
  if [[ -z "${IMAGE_VERSION}" ]]; then
    local IMAGE_URL="gcr.io/$PROJECT_ID/$IMAGE_NAME"
  else
    local IMAGE_URL="gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_VERSION"
  fi

  local _LABELS=()

  if [[ ! -z "$_TRIGGER_ID" ]]; then
    _LABELS+=("gcb-trigger-id=$_TRIGGER_ID")
  fi

  if [[ ! -z "$COMMIT_SHA" ]]; then
    _LABELS+=("commit-sha=$COMMIT_SHA")
  fi

  if [[ ! -z "$BUILD_ID" ]]; then
    _LABELS+=("gcb-build-id=$BUILD_ID")
  fi

  if [[ ${#_LABELS[@]} -gt 0 ]]; then
    local LABELS="--labels=$(echo ${_LABELS[@]} | tr ' ' ',')"
  fi

  gcloud beta run deploy $IMAGE_NAME --platform=managed --allow-unauthenticated --image=$IMAGE_URL --region=$REGION --ingress=internal-and-cloud-load-balancing $LABELS --project $PROJECT_ID &> /dev/null
  set +e

  echo -e "Deployed $IMAGE_NAME in $REGION\n"
}

for REGION in $REGIONS; do
  deploy $REGION &
done

for job in `jobs -p`; do
  wait ${job}
done

for REGION in $REGIONS; do
  NEG_NAME=$IMAGE_NAME-neg-$REGION

  gcloud beta compute network-endpoint-groups describe $NEG_NAME --region=$REGION --project $PROJECT_ID &> /dev/null

  if [ $? -ne 0 ]; then
    set -e
    gcloud beta compute network-endpoint-groups create $NEG_NAME --region=$REGION --network-endpoint-type=SERVERLESS --cloud-run-service=$IMAGE_NAME --project $PROJECT_ID
    set +e
  fi

  if [[ "$BACKEND_NEGS" != *"$NEG_NAME"* ]]; then
    set -e
    gcloud beta compute backend-services add-backend --global $BACKEND_NAME --network-endpoint-group-region=$REGION --network-endpoint-group=$NEG_NAME --project $PROJECT_ID
    set +e
  fi
done

readonly LB_IP=$(gcloud compute addresses describe --global $SERVICE_IP --format='value(address)' --project $PROJECT_ID)

echo -e "\nPoint $DOMAINS to $LB_IP\n"

echo -e "Check the status of your ssl-certificate with:\n"
echo "gcloud beta compute ssl-certificates describe $CERT_NAME \\"
echo "  --project $PROJECT_ID --format=\"value(managed.status)\""
