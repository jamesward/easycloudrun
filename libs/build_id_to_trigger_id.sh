#!/usr/bin/env bash

if [[ -z "${PROJECT_ID}" ]]; then
  echo "PROJECT_ID env var not set"
  exit 1
fi

if [[ -z "${BUILD_ID}" ]]; then
  echo "BUILD_ID env var not set"
else
  export _TRIGGER_ID=$(gcloud builds describe ${BUILD_ID} --project=${PROJECT_ID} --format='value(buildTriggerId)')
fi

