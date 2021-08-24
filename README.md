Easy Cloud Run
--------------

Tools for automating Cloud Run stuff for use on your machine, Cloud Build, and GitHub Actions.


## deploy

Does a `gcloud run deploy` with a dedicated service account and sets the CI/CD details on the service if the `BUILD_ID` env var is set (which it is on Cloud Build)

<details>
    <summary>Required APIs</summary>

- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [containerregistry.googleapis.com](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Security Admin|`roles/iam.securityAdmin`|
|Service Account Admin|`roles/iam.serviceAccountAdmin`|
|Service Account User|`roles/iam.serviceAccountUser`|
|Cloud Run Admin|`roles/run.admin`|
</details>

<details>
    <summary>Run Locally</summary>

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
  ghcr.io/jamesward/easycloudruneasycloudrun
```
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: deploy
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
</details>

<details>
    <summary>GitHub Actions</summary>

Setup GitHub Actions secrets: `GCP_PROJECT`, `GCP_REGION`, `GCP_CREDENTIALS` (the JSON for a service account with the required roles)

```yaml
steps:
  - name: Setup gcloud
    uses: google-github-actions/setup-gcloud@v0.2
    with:
      project_id: ${{ secrets.GCP_PROJECT }}
      service_account_key: ${{ secrets.GCP_CREDENTIALS }}
      export_default_credentials: true

  - name: Deploy
    uses: jamesward/easycloudrun/deploy@main
    env:
      PROJECT_ID: ${{ secrets.GCP_PROJECT }}
      COMMIT_SHA: ${{ github.sha }}
      IMAGE_NAME: ${{ github.event.repository.name }}
      IMAGE_VERSION: ${{ github.sha }}
      REGION: ${{ secrets.GCP_REGION }}
```
</details>


## appsecret

Sets a generated env var in the .env file if the Cloud Run service does not already have one

<details>
    <summary>Required APIs</summary>

- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Cloud Run Admin|`roles/run.admin`|
</details>

<details>
    <summary>Run Locally</summary>

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
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: appsecret
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'ENV_NAME=YOUR_ENV_NAME'
      - 'REGION=YOUR_REGION'
```
</details>

<details>
    <summary>GitHub Actions</summary>

    TODO
</details>


## deploywithenvs

Like `deploy` but automatically adds `--update-env-vars` for everything in a `.env` file

<details>
    <summary>Required APIs</summary>

- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [containerregistry.googleapis.com](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Security Admin|`roles/iam.securityAdmin`|
|Service Account Admin|`roles/iam.serviceAccountAdmin`|
|Cloud Run Admin|`roles/run.admin`|
|Service Account User|`roles/iam.serviceAccountUser`|
</details>

<details>
    <summary>Run Locally</summary>

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
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
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
</details>

<details>
    <summary>GitHub Actions</summary>

    TODO
</details>


## multiregion

Deploy a service to all available regions and setup a GCLB in front

<details>
    <summary>Required APIs</summary>

- [servicenetworking.googleapis.com](https://console.cloud.google.com/apis/library/servicenetworking.googleapis.com)
- [sqladmin.googleapis.com](https://console.cloud.google.com/apis/library/sqladmin.googleapis.com)
- [vpcaccess.googleapis.com](https://console.cloud.google.com/apis/library/vpcaccess.googleapis.com)
- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [containerregistry.googleapis.com](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Security Admin|`roles/iam.securityAdmin`|
|Service Account Admin|`roles/iam.serviceAccountAdmin`|
|Cloud Run Admin|`roles/run.admin`|
|Compute Network Admin|`roles/compute.networkAdmin`|
|Compute Instance Admin|`roles/compute.instanceAdmin.v1`|
|Service Account User|`roles/iam.serviceAccountUser`|
</details>

<details>
    <summary>Run Locally</summary>

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
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
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
</details>

<details>
    <summary>GitHub Actions</summary>

    TODO
</details>


## vpcsql

Create a Cloud SQL instance in a VPC, deploy a Cloud Run service connected to that database

<details>
    <summary>Required APIs</summary>

- [servicenetworking.googleapis.com](https://console.cloud.google.com/apis/library/servicenetworking.googleapis.com)
- [sqladmin.googleapis.com](https://console.cloud.google.com/apis/library/sqladmin.googleapis.com)
- [vpcaccess.googleapis.com](https://console.cloud.google.com/apis/library/vpcaccess.googleapis.com)
- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [containerregistry.googleapis.com](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Compute Network Admin|`roles/compute.networkAdmin`|
|Compute Instance Admin|`roles/compute.instanceAdmin.v1`|
|Cloud SQL Admin|`roles/cloudsql.admin`|
|Service Account User|`roles/iam.serviceAccountUser`|
|Serverless VPC Access Admin|`roles/vpcaccess.admin`|
</details>

<details>
    <summary>Run Locally</summary>

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
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
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

timeout: 30m
```
</details>

<details>
    <summary>GitHub Actions</summary>

```yaml
steps:
  - name: Setup gcloud
    uses: google-github-actions/setup-gcloud@v0.2
    with:
      project_id: ${{ secrets.GCP_PROJECT }}
      service_account_key: ${{ secrets.GCP_CREDENTIALS }}
      export_default_credentials: true

  - name: Deploy
    uses: jamesward/easycloudrun/vpcsql@main
    env:
      PROJECT_ID: ${{ secrets.GCP_PROJECT }}
      COMMIT_SHA: ${{ github.sha }}
      IMAGE_NAME: ${{ github.event.repository.name }}
      IMAGE_VERSION: ${{ github.sha }}
      REGION: ${{ secrets.GCP_REGION }}
      DB_VERSION: YOUR_DB_VERSION
      DB_TIER: YOUR_DB_TIER
      DB_INIT_ARGS: OPTIONAL_CONTAINER_ARGS_FOR_DB_INIT
```
</details>


## staticandapi

Setup a load balancer where `/` is static and `/something` is backed by a Cloud Run service

<details>
    <summary>Required APIs</summary>

- [servicenetworking.googleapis.com](https://console.cloud.google.com/apis/library/servicenetworking.googleapis.com)
- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [containerregistry.googleapis.com](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Compute Network Admin|`roles/compute.networkAdmin`|
|Service Account User|`roles/iam.serviceAccountUser`|
|Cloud Run Admin|`roles/run.admin`|
</details>

<details>
    <summary>Run Locally</summary>

```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export REGION=YOUR_REGION
export DOMAINS=YOUR_DOMAINS
export FILE_PATH=YOUR_FILE_PATH
export API_PATH=YOUR_API_PATH # Defaults to /api
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eREGION=$REGION \
  -eDOMAINS=$DOMAINS \
  -eFILE_PATH=$FILE_PATH \
  -eAPI_PATH=$API_PATH \
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=staticandapi \
  ghcr.io/jamesward/easycloudrun
```
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: staticandapi
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'REGION=YOUR_REGION'
      - 'DOMAINS=YOUR_DOMAINS'
      - 'FILE_PATH=YOUR_PATH_TO_STATIC_FILES'
      - 'API_PATH=YOUR_PATH_TO_ROUTE_TO_CLOUD_RUN'
```
</details>

<details>
    <summary>GitHub Actions</summary>

    TODO
</details>



## pubsubhandler

Deploys a Cloud Run service which handles Pub/Sub events.

<details>
    <summary>Required APIs</summary>

- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [containerregistry.googleapis.com](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)
- [pubsub.googleapis.com](https://console.cloud.google.com/apis/library/pubsub.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Security Admin|`roles/iam.securityAdmin`|
|Service Account Admin|`roles/iam.serviceAccountAdmin`|
|Service Account User|`roles/iam.serviceAccountUser`|
|Cloud Run Admin|`roles/run.admin`|
|Pub/Sub Editor|`roles/pubsub.editor`|
</details>

<details>
    <summary>Run Locally</summary>

```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export IMAGE_VERSION=OPTIONAL_IMAGE_VERSION
export REGION=us-central1 # or whatever region you want
export DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS
export ROLES=OPTIONAL_ROLES_COMMA_SEPARATED
export TOPIC=PUBSUB_TOPIC
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eIMAGE_VERSION=$IMAGE_VERSION \
  -eREGION=$REGION \
  -eDEPLOY_OPTS=$DEPLOY_OPTS \
  -eROLES=$ROLES \
  -eTOPIC=$TOPIC \
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=pubsubhandler \
  ghcr.io/jamesward/easycloudruneasycloudrun
```
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: pubsubhandler
    env:
      - 'PROJECT_ID=$PROJECT_ID'
      - 'BUILD_ID=$BUILD_ID'
      - 'COMMIT_SHA=$COMMIT_SHA'
      - 'IMAGE_NAME=$REPO_NAME'
      - 'IMAGE_VERSION=$COMMIT_SHA'
      - 'REGION=YOUR_REGION'
      - 'DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS'
      - 'ROLES=OPTIONAL_ROLES_COMMA_SEPARATED'
      - 'TOPIC=PUBSUB_TOPIC'
```
</details>

<details>
    <summary>GitHub Actions</summary>

Setup GitHub Actions secrets: `GCP_PROJECT`, `GCP_REGION`, `GCP_CREDENTIALS` (the JSON for a service account with the required roles), `PUBSUB_TOPIC`

```yaml
steps:
  - name: Setup gcloud
    uses: google-github-actions/setup-gcloud@v0.2
    with:
      project_id: ${{ secrets.GCP_PROJECT }}
      service_account_key: ${{ secrets.GCP_CREDENTIALS }}
      export_default_credentials: true

  - name: Deploy
    uses: jamesward/easycloudrun/pubsubhandler@main
    env:
      PROJECT_ID: ${{ secrets.GCP_PROJECT }}
      COMMIT_SHA: ${{ github.sha }}
      IMAGE_NAME: ${{ github.event.repository.name }}
      IMAGE_VERSION: ${{ github.sha }}
      REGION: ${{ secrets.GCP_REGION }}
      TOPIC: ${{ secrets.PUBSUB_TOPIC }}
```
</details>

## listservices

<details>
    <summary>Required APIs</summary>

- [run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)
</details>

<details>
    <summary>Required Roles</summary>

| Name | Role |
|------|------|
|Cloud Run Admin|`roles/run.admin`|
</details>

<details>
    <summary>Run Locally</summary>

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
</details>

<details>
    <summary>Cloud Build</summary>

```yaml
steps:
  - name: ghcr.io/jamesward/easycloudrun
    entrypoint: listservices
    env:
      - 'PROJECT_ID=$PROJECT_ID'
```
</details>

<details>
    <summary>GitHub Actions</summary>

    TODO
</details>
