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


readonly SVC_ACCOUNT=$IMAGE_NAME@$PROJECT_ID.iam.gserviceaccount.com

gcloud iam service-accounts describe $SVC_ACCOUNT --project $PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud iam service-accounts create $IMAGE_NAME --project $PROJECT_ID
  set +e
fi

readonly _EXISTING_ROLES=$(gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --format='value(bindings.role)' \
  --filter="bindings.members:$SVC_ACCOUNT")

for role in $_EXISTING_ROLES; do
  set -e
  gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SVC_ACCOUNT" \
    --role=$role \
    &> /dev/null
  set +e
done

_ROLES=${ROLES//,/ }

for role in $_ROLES; do
  set -e
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SVC_ACCOUNT" \
    --role=$role \
    &> /dev/null
  set +e
done


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

