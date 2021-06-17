Easy Cloud Run
--------------

Tools for automating Cloud Run stuff for use on your machine, Cloud Build, and GitHub Actions.


## Cloud Build Setup

- Add roles to the Cloud Build service account:

    | Name | Role |
    |------|------|
    |Security Admin|`roles/iam.securityAdmin`|
    |Service Account Admin|`roles/iam.serviceAccountAdmin`|
    |Cloud Run Admin|`roles/run.admin`|

## multiregion

Deploy a service to all available regions and setup a GCLB in front

Required Roles: Compute Admin, Cloud Run Admin, ???

Run Locally:
```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export IMAGE_VERSION=OPTIONAL_IMAGE_VERSION
export DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS
export ROLES=OPTIONAL_ROLES_COMMA_SEPARATED
export DOMAINS=YOUR_DOMAIN
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eIMAGE_VERSION=$IMAGE_VERSION \
  -eDEPLOY_OPTS=$DEPLOY_OPTS \
  -eROLES=$ROLES \
  -eDOMAINS=$DOMAINS \
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=multiregion \
  ghcr.io/jamesward/easycloudrun
```

Cloud Build:
```
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: multiregion
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'BUILD_ID=$BUILD_ID'
      - 'COMMIT_SHA=$COMMIT_SHA'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'IMAGE_VERSION=$COMMIT_SHA'
      - 'DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS'
      - 'ROLES=OPTIONAL_ROLES_COMMA_SEPARATED'
      - 'DOMAINS=YOUR_DOMAIN'
```

GitHub Actions:
```
TODO
```


## deploywithenvs

Does a `gcloud run deploy` but automatically adds `--update-env-vars` for everything in a `.env` file.

Run Locally:
```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export IMAGE_VERSION=OPTIONAL_IMAGE_VERSION
export REGION=us-central1 # or whatever region you want
export DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS
export ROLES=OPTIONAL_ROLES_COMMA_SEPARATED
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eIMAGE_VERSION=$IMAGE_VERSION \
  -eREGION=$REGION \
  -eDEPLOY_OPTS=$DEPLOY_OPTS \
  -eROLES=$ROLES \
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=deploywithenvs \
  ghcr.io/jamesward/easycloudrun
```

Cloud Build:
```
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: deploywithenvs
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'BUILD_ID=$BUILD_ID'
      - 'COMMIT_SHA=$COMMIT_SHA'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'IMAGE_VERSION=$COMMIT_SHA'
      - 'REGION=YOUR_REGION'
      - 'DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS'
      - 'ROLES=OPTIONAL_ROLES_COMMA_SEPARATED'
```


## deploy

Does a `gcloud run deploy`

Run Locally:
```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export IMAGE_VERSION=OPTIONAL_IMAGE_VERSION
export REGION=us-central1 # or whatever region you want
export DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS
export ROLES=OPTIONAL_ROLES_COMMA_SEPARATED
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eIMAGE_VERSION=$IMAGE_VERSION \
  -eREGION=$REGION \
  -eDEPLOY_OPTS=$DEPLOY_OPTS \
  -eROLES=$ROLES \
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=deploy \
  ghcr.io/jamesward/easycloudrun
```

Cloud Build:
```
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: deploywithenvs
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'BUILD_ID=$BUILD_ID'
      - 'COMMIT_SHA=$COMMIT_SHA'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'IMAGE_VERSION=$COMMIT_SHA'
      - 'REGION=YOUR_REGION'
      - 'DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS'
      - 'ROLES=OPTIONAL_ROLES_COMMA_SEPARATED'
```


## appsecret

Sets a generated env var in the .env file if the Cloud Run service does not already have one.

Run Locally:
```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export ENV_NAME=YOUR_SECRETS_ENV_NAME
export REGION=YOUR_REGION
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

# todo: need a way to read the env file out
docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eENV_NAME=$ENV_NAME \
  -eREGION=$REGION \
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=appsecret \
  ghcr.io/jamesward/easycloudrun
```

Cloud Build:
```
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: appsecret
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'ENV_NAME=YOUR_ENV_NAME'
      - 'REGION=YOUR_REGION'
```

GitHub Actions:
```
TODO
```


## vpcsql

Create a Cloud SQL instance in a VPC, deploy a Cloud Run service connected to that database

Required APIs:
- [servicenetworking.googleapis.com](https://console.cloud.google.com/apis/library/servicenetworking.googleapis.com)
- [sqladmin.googleapis.com](https://console.cloud.google.com/apis/library/sqladmin.googleapis.com)
- [vpcaccess.googleapis.com](https://console.cloud.google.com/apis/library/vpcaccess.googleapis.com)
- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [containerregistry.googleapis.com](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)

Required Cloud Build Service Account roles:

    | Name | Role |
    |------|------|
    |Compute Network Admin|`roles/compute.networkAdmin`|
    |Compute Instance Admin|`roles/compute.instanceAdmin.v1`|
    |Compute SQL Admin|`roles/cloudsql.admin`|
    |Service Account User|`roles/iam.serviceAccountUser`|
    |Serverless VPC Access Admin|`roles/vpcaccess.admin`|

Run Locally:
```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export REGION=YOUR_REGION
export DB_VERSION=YOUR_DB_VERSION # like: POSTGRES_13
export DB_TIER=YOUR_DB_TIER # like: db-f1-micro
export DB_INIT_ARGS=OPTIONAL_CONTAINER_ARGS_FOR_DB_INIT
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eREGION=$REGION \
  -eDB_VERSION=$DB_VERSION \
  -eDB_TIER=$DB_TIER \
  -eDB_INIT_ARGS=$DB_INIT_ARGS \
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=vpcsql \
  ghcr.io/jamesward/easycloudrun
```

Cloud Build:
```
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: vpcsql
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'REGION=YOUR_REGION'
      - 'DB_VERSION=YOUR_DB_VERSION'
      - 'DB_TIER=YOUR_DB_TIER'
      - 'DB_INIT_ARGS=OPTIONAL_CONTAINER_ARGS_FOR_DB_INIT'

timeout: 20m
```

GitHub Actions:
```
TODO
```


## listservices

Run Locally:
```
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON
export PROJECT_ID=YOUR_PROJECT_ID

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=listservices \
  ghcr.io/jamesward/easycloudrun
```

Cloud Build:
- Service Account Roles: TODO
```
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: listservices
    env:
      - 'PROJECT_ID=$PROJECT_ID'
```

GitHub Actions:
```
TODO
```
