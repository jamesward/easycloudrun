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

if [[ -z "${REGION}" ]]; then
  echo "REGION env var not set"
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. $DIR/libs/build_id_to_trigger_id.sh

if [[ -f ".env" ]]; then
  readarray -t _ENVS < .env

  if [[ ${#_ENVS[@]} -gt 0 ]]; then
    export DEPLOY_OPTS="$DEPLOY_OPTS --update-env-vars=$(echo ${_ENVS[@]} | tr ' ' ',')"
  fi
fi

$DIR/libs/deploy.sh

