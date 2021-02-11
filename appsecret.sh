#!/usr/bin/env bash
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

if [[ -z "${ENV_NAME}" ]]; then
  echo "ENV_NAME env var not set"
  exit 1
fi

if [[ -z "${REGION}" ]]; then
  echo "REGION env var not set"
  exit 1
fi

gcloud run services describe $IMAGE_NAME --project=$PROJECT_ID --platform=managed --region=$REGION --format='config(spec.template.spec.containers[0].env)' | grep "name = $ENV_NAME" &> /dev/null

# if the service or the env var does not exist, set it
if [ $? -ne 0 ]; then
  readonly ENV_VALUE=$(head -c 64 /dev/urandom | base64 -w0)
  echo "$ENV_NAME=$ENV_VALUE" >> .env
fi

