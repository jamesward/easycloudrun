#!/usr/bin/env bash
#
# Runs a one-off container on GCE
#
# todo: wait for completion

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

if [[ -z "${NETWORK}" ]]; then
  echo "NETWORK env var not set"
  exit 1
fi

if [[ -z "${SUBNET}" ]]; then
  echo "SUBNET env var not set"
  exit 1
fi

if [[ -z "${ENVS}" ]]; then
  echo "ENVS env var not set"
  exit 1
fi

if [[ -z "${DB_INIT_ARGS}" ]]; then
  echo "DB_INIT_ARGS env var not set"
  exit 1
fi

if [[ -z "${INSTANCE_NAME}" ]]; then
  echo "INSTANCE_NAME env var not set"
  exit 1
fi

# todo: --container-command=

# todo: --service-account=

# todo: configurable
declare zone=$REGION-a

# todo: configurable
declare machineType=e2-small

# todo: no-network

declare dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

gcloud compute instances create-with-container $INSTANCE_NAME \
    --container-restart-policy=never \
    --no-restart-on-failure \
    --scopes=cloud-platform \
    --container-stdin \
    --container-tty \
    --metadata-from-file=startup-script=$dir/gce_startup_script.sh \
    --container-image=gcr.io/$PROJECT_ID/$IMAGE_NAME \
    --container-arg=$DB_INIT_ARGS \
    --container-env=$ENVS \
    --network=$NETWORK \
    --subnet=$SUBNET \
    --zone=$zone \
    --machine-type=$machineType \
    --project=$PROJECT_ID
