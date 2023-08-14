#!/usr/bin/env bash
#
# optional env var params:
#   _TRIGGER_ID
#   DEPLOY_OPTS
#   ROLES
#
# todo: --platform=gke
#

#set -uxo pipefail

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

if [[ -z "${IMAGE_VERSION}" ]]; then
  readonly IMAGE_URL="gcr.io/$PROJECT_ID/$IMAGE_NAME"
else
  readonly IMAGE_URL="gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_VERSION"
fi

_LABELS=()

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
  readonly LABELS="--labels=$(echo ${_LABELS[@]} | tr ' ' ',')"
fi

set +e

# default to allow-unauthenticated
if [[ $DEPLOY_OPTS != *"--no-allow-unauthenticated"* ]]; then
  DEPLOY_OPTS="--allow-unauthenticated $DEPLOY_OPTS"
fi

gcloud beta run deploy $IMAGE_NAME \
  --platform=managed \
  --image=$IMAGE_URL \
  --region=$REGION \
  --service-account=$SVC_ACCOUNT \
  $LABELS \
  $DEPLOY_OPTS \
  --project=$PROJECT_ID

# todo: on deploy error, show it
if [ $? -ne 0 ]; then
  echo "Error deploying $IMAGE_NAME in $REGION"
else
  echo "Deployed $IMAGE_NAME in $REGION"
fi
