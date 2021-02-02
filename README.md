Easy Cloud Run
--------------

Tools for automating Cloud Run stuff for use on your machine, Cloud Build, and GitHub Actions.

## multiregion

Deploy a service to all available regions and setup a GCLB in front

Run Locally:
```
export DOMAIN???
export GOOGLE_APPLICATION_CREDENTIALS=YOUR_TEST_CREDS_JSON

docker run --rm \
  -eDOMAIN???
  -eCLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/certs/svc_account.json \
  -v$GOOGLE_APPLICATION_CREDENTIALS:/certs/svc_account.json \
  --entrypoint=multiregion \
  ghcr.io/jamesward/easycloudrun
```

Cloud Build:
- Service Account Roles: TODO
```
TODO
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
```

GitHub Actions:
```
TODO
```
