#!/usr/bin/env bash
#

#set -uxo pipefail

export CLOUDSDK_CORE_DISABLE_PROMPTS=1

if [[ -z "${PROJECT_ID}" ]]; then
  echo "PROJECT_ID env var not set"
  exit 1
fi

if [[ -z "${REGION}" ]]; then
  echo "REGION env var not set"
  exit 1
fi

if [[ -z "${IMAGE_NAME}" ]]; then
  echo "IMAGE_NAME env var not set"
  exit 1
fi

if [[ -z "${TOPIC}" ]]; then
  echo "TOPIC env var not set"
  exit 1
fi


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. $DIR/libs/build_id_to_trigger_id.sh

. $DIR/libs/svc_account.sh

. $DIR/libs/invoker_svc_account.sh


export DEPLOY_OPTS="--ingress=internal --no-allow-unauthenticated $DEPLOY_OPTS"

$DIR/libs/deploy.sh

gcloud pubsub topics describe $TOPIC --project=$PROJECT_ID  &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud pubsub topics create $TOPIC --project=$PROJECT_ID
  set +e
fi

gcloud pubsub subscriptions describe --project=$PROJECT_ID $IMAGE_NAME &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  SERVICE_URL=$(gcloud run services describe $IMAGE_NAME --platform=managed --region=$REGION --project=$PROJECT_ID --format='value(status.url)')

  gcloud pubsub subscriptions create $IMAGE_NAME \
    --topic $TOPIC \
    --project=$PROJECT_ID \
    --push-endpoint=$SERVICE_URL/ \
    --push-auth-service-account=$INVOKER_SVC_ACCOUNT

  PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

  PUBSUB_SERVICE_ACCOUNT="service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com"

  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${PUBSUB_SERVICE_ACCOUNT}" \
    --role='roles/iam.serviceAccountTokenCreator' \
    &> /dev/null

  set +e
fi
