#!/usr/bin/env bash
#
# optional env var params:
#   _TRIGGER_ID
#   DEPLOY_OPTS
#   ROLES
#
# todo: --platform=gke
# todo: --no-allow-unauthenticated
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

gcloud run deploy $IMAGE_NAME \
  --allow-unauthenticated \
  --platform=managed \
  --image=$IMAGE_URL \
  --region=$REGION \
  --service-account=$SVC_ACCOUNT \
  $LABELS \
  $DEPLOY_OPTS \
  --project=$PROJECT_ID \
  &> /dev/null

# todo: on deploy error, show it

set +e

echo -e "Deployed $IMAGE_NAME in $REGION\n"

