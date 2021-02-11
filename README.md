Easy Cloud Run
--------------

Tools for automating Cloud Run stuff for use on your machine, Cloud Build, and GitHub Actions.

## multiregion

Deploy a service to all available regions and setup a GCLB in front

Required Roles: Compute Admin, Cloud Run Admin, ???

Run Locally:
```
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=YOUR_GCR_IMAGE_NAME # gcr.io/YOUR_PROJECT/IMAGE_NAME
export IMAGE_VERSION=OPTIONAL_IMAGE_VERSION
export DOMAINS=YOUR_DOMAIN
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eIMAGE_VERSION=$IMAGE_VERSION \
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
export _DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTIONS
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -ePROJECT_ID=$PROJECT_ID \
  -eIMAGE_NAME=$IMAGE_NAME \
  -eIMAGE_VERSION=$IMAGE_VERSION \
  -eREGION=$REGION \
  -e_DEPLOY_OPTS=$_DEPLOY_OPTS \
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
      - '_DEPLOY_OPTS=OPTIONAL_DEPLOY_OPTS'
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
