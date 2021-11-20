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
declare SVC_ACCOUNT_NAME=${IMAGE_NAME:0:26}-run

export SVC_ACCOUNT=$SVC_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com

gcloud iam service-accounts describe $SVC_ACCOUNT --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e
  gcloud iam service-accounts create $SVC_ACCOUNT_NAME --project=$PROJECT_ID
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

# todo: display error if adding a role fails
for role in $_ROLES; do
  echo "Adding Role $role to $SVC_ACCOUNT"
  set -e
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SVC_ACCOUNT" \
    --role=$role \
    &> /dev/null
  set +e
done
