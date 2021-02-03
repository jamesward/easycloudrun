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
      - 'IMAGE_NAME=$REPO_NAME'
      - 'IMAGE_VERSION=$COMMIT_SHA'
      - 'DOMAINS=YOUR_DOMAIN'
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
