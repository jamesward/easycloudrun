#!/usr/bin/env bash
#
# optional env var params:
#   ROLES
#
# todo: --platform=gke
# todo: --no-allow-unauthenticated
#

# max length is 30
# todo: min length
declare INVOKER_SVC_ACCOUNT_NAME=${IMAGE_NAME:0:22}-invoker

export INVOKER_SVC_ACCOUNT=$INVOKER_SVC_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com

gcloud iam service-accounts describe $INVOKER_SVC_ACCOUNT --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud iam service-accounts create $INVOKER_SVC_ACCOUNT_NAME --project=$PROJECT_ID
  set +e
fi

set -e
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$INVOKER_SVC_ACCOUNT" \
  --role=roles/run.invoker \
  &> /dev/null
set +e
