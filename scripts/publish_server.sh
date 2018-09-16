#!/bin/bash
set -e

REPO_BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GO_ROOT="${REPO_BASE}/go/src/"
GCLOUD_SERVICE_ACCOUNT_KEY_JSON=${HOME}/gcloud-service-account-key.json

echo $GCLOUD_SERVICE_ACCOUNT_KEY | base64 --decode -i > $GCLOUD_SERVICE_ACCOUNT_KEY_JSON
gcloud auth activate-service-account --key-file $GCLOUD_SERVICE_ACCOUNT_KEY_JSON

gcloud --quiet config set compute/zone $GCLOUD_COMPUTE_ZONE
gcloud --quiet config set project $PROJECT_NAME

gcloud builds submit --tag gcr.io/trial-194900/go-werewolf:latest $GO_ROOT
gcloud compute instances reset $GCLOUD_VM_INSTANCE
