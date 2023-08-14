#!/usr/bin/env bash
#
# todo: IMAGE_VERSION
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

if [[ $DB_VERSION != POSTGRES_* && $DB_VERSION != MYSQL_* ]]; then
  echo "DB_VERSION env var not set or invalid"
  exit 1
fi

if [[ -z "${DB_TIER}" ]]; then
  echo "DB_TIER env var not set"
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. $DIR/libs/build_id_to_trigger_id.sh

. $DIR/libs/svc_account.sh

# Once an instance is created with a name, you can never create another with the same name, even after it is deleted.
# So we pick a random 8 numbers to append to the instance name.
#declare instance="$IMAGE_NAME-$(cat /dev/urandom | tr -dc '0-9' | fold -w 8 | head -n 1)"
declare instance=$IMAGE_NAME-$REGION

# VPC

declare rand1=$(( ( RANDOM % 63 ) + 1 ))
declare rand2=$(( rand1 + 1 ))

gcloud compute networks describe $instance --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  echo "Creating network: $instance"

  gcloud compute networks create $instance \
      --subnet-mode=custom \
      --project=$PROJECT_ID

  gcloud compute networks subnets create $instance \
    --network=$instance \
    --range="10.$rand1.0.0/28" \
    --region=$REGION \
    --project=$PROJECT_ID

  set +e
fi

export DEPLOY_OPTS="$DEPLOY_OPTS --network=$instance --subnet=$instance --vpc-egress=private-ranges-only"

# SQL

gcloud beta sql instances describe $instance --project=$PROJECT_ID &> /dev/null

if [ $? -ne 0 ]; then
  set -e

  echo "Creating Cloud SQL instance named $instance"

  declare db_user=postgres
  declare db_pass=$(dd bs=24 count=1 if=/dev/urandom status=none | base64 | tr +/ _.)
  declare db_name=postgres

  declare operation=$(gcloud beta sql instances create $instance \
      --database-version=$DB_VERSION \
      --tier=$DB_TIER \
      --region=$REGION \
      --project=$PROJECT_ID \
      --root-password=$db_pass \
      --network=$instance \
      --no-assign-ip \
      --async \
      --format='value(name)')

  # the create operation times out so we do it async and then wait
  gcloud beta sql operations wait $operation \
      --timeout=unlimited \
      --project=$PROJECT_ID

  declare db_host=$(gcloud sql instances describe $instance \
      --project=$PROJECT_ID \
      --format='value(ipAddresses.ipAddress)')

  if [[ $DB_VERSION == POSTGRES_* ]]; then
    declare db_protocol="postgres"
  elif [[ $DB_VERSION == MYSQL_* ]]; then
    declare db_protocol="mysql"
  fi

  declare DATABASE_URL="$db_protocol://$db_user:$db_pass@$db_host/$db_name"

  # todo: get zone where db was created and pass it to one_off_gce
  if [[ ! -z $DB_INIT_ARGS ]]; then
    export NETWORK=$instance
    export SUBNET=$instance
    export ENVS="DATABASE_URL=$DATABASE_URL"
    export INSTANCE_NAME=$instance-db-setup
    $DIR/libs/one_off_gce.sh
  fi

  export DEPLOY_OPTS="$DEPLOY_OPTS --update-env-vars=DATABASE_URL=$DATABASE_URL"

  set +e
fi

# Cloud Run
set -e
$DIR/libs/deploy.sh

if [ $? -ne 0 ]; then
  exit 1
fi
