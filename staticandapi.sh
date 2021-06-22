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

if [[ -z "${REGION}" ]]; then
  echo "REGION env var not set"
  exit 1
fi

if [[ -z "${DOMAINS}" ]]; then
  echo "DOMAINS env var not set"
  exit 1
fi

if [[ -z "${FILE_PATH}" ]]; then
  echo "FILE_PATH env var not set"
  exit 1
elif [[ ! -d "${FILE_PATH}" ]]; then
  echo "FILE_PATH ($FILE_PATH) does not exist or is not a directory"
  exit 1
fi

if [[ -z "${API_PATH}" ]]; then
  API_PATH="/api"
fi


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"



# Bucket

# todo: branch name in bucket

declare bucket="$PROJECT_ID-$IMAGE_NAME"

gsutil label get gs://$bucket &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gsutil mb -p $PROJECT_ID -c standard -l $REGION -b on gs://$bucket

  set +e
fi

set -e

gsutil cp $FILE_PATH/** gs://$bucket

gsutil iam ch allUsers:objectViewer gs://$bucket

gsutil web set -m index.html gs://$bucket

set +e


# GCLB

#declare instance="$IMAGE_NAME-$(cat /dev/urandom | tr -dc '0-9' | fold -w 8 | head -n 1)"
declare instance=$IMAGE_NAME

gcloud compute addresses describe $instance-ip --global --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute addresses create $instance-ip \
    --network-tier=PREMIUM \
    --ip-version=IPV4 \
    --global \
    --project=$PROJECT_ID

  set +e
fi

declare ip=$(gcloud compute addresses describe $instance-ip --format="get(address)" --global --project=$PROJECT_ID)

gcloud compute backend-buckets describe $instance-bucket --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute backend-buckets create $instance-bucket \
    --gcs-bucket-name=$bucket \
    --enable-cdn \
    --project=$PROJECT_ID

  set +e
fi

gcloud compute backend-services describe $instance-service --global --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute backend-services create $instance-service \
    --global \
    --project=$PROJECT_ID

  set +e
fi

gcloud beta compute network-endpoint-groups describe $instance-neg-$REGION --region=$REGION --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud beta compute network-endpoint-groups create $instance-neg-$REGION \
    --region=$REGION \
    --network-endpoint-type=SERVERLESS \
    --cloud-run-service=$instance \
    --project=$PROJECT_ID

  gcloud compute backend-services add-backend $instance-service \
    --global \
    --network-endpoint-group-region=$REGION \
    --network-endpoint-group=$instance-neg-$REGION \
    --project=$PROJECT_ID

  set +e
fi

gcloud compute url-maps describe $instance-url-map --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute url-maps create $instance-url-map \
    --global \
    --default-backend-bucket=$instance-bucket \
    --project=$PROJECT_ID

  gcloud compute url-maps add-path-matcher $instance-url-map \
    --path-matcher-name=api-matcher \
    --path-rules=$API_PATH/*=$instance-service \
    --default-backend-bucket=$instance-bucket \
    --project=$PROJECT_ID

  set +e
fi

# todo: if DOMAINS changes, update
gcloud beta compute ssl-certificates describe $instance-cert --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud beta compute ssl-certificates create $instance-cert \
    --domains=$DOMAINS \
    --project=$PROJECT_ID

  set +e
fi

gcloud compute target-https-proxies describe $instance-https-proxy --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute target-https-proxies create $instance-https-proxy \
    --url-map=$instance-url-map \
    --ssl-certificates=$instance-cert \
    --project=$PROJECT_ID

  set +e
fi

gcloud compute forwarding-rules describe $instance-https --global --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute forwarding-rules create $instance-https \
    --address=$ip \
    --global \
    --target-https-proxy=$instance-https-proxy \
    --ports=443 \
    --project=$PROJECT_ID

  set +e
fi

gcloud compute url-maps describe $instance-httpredirect --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  # http to https redirect

  gcloud compute url-maps import $instance-httpredirect \
    --global \
    --source=/dev/stdin \
    --project=$PROJECT_ID <<EOF
name: $instance-httpredirect
defaultUrlRedirect:
  redirectResponseCode: MOVED_PERMANENTLY_DEFAULT
  httpsRedirect: True
EOF

  set +e
fi

gcloud compute target-http-proxies describe $instance-http-proxy --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute target-http-proxies create $instance-http-proxy \
    --url-map=$instance-httpredirect \
    --project=$PROJECT_ID

  set +e
fi

gcloud compute forwarding-rules describe $instance-http --global --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  gcloud compute forwarding-rules create $instance-http \
    --address=$ip \
    --global \
    --target-http-proxy=$instance-http-proxy \
    --ports=80 \
    --project=$PROJECT_ID

  set +e
fi


# Deploy Cloud Run Service

. $DIR/libs/build_id_to_trigger_id.sh

. $DIR/libs/svc_account.sh

export DEPLOY_OPTS="--ingress=internal-and-cloud-load-balancing $DEPLOY_OPTS"

$DIR/libs/deploy.sh


# Info for user

readonly LB_IP=$(gcloud compute addresses describe $instance-ip --global --format='value(address)' --project=$PROJECT_ID)

echo -e "\nPoint $DOMAINS to $LB_IP\n"

echo -e "Check the status of your ssl-certificate with:\n"
echo "gcloud beta compute ssl-certificates describe $instance-cert \\"
echo "  --project $PROJECT_ID --format=\"value(managed.status)\""
