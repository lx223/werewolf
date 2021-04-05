#!/bin/bash
set -e

REPO_BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GO_ROOT="${REPO_BASE}/go/server/"

gcloud --quiet config set compute/zone $GCE_INSTANCE_ZONE
gcloud --quiet config set project $GCE_PROJECT

gcloud builds submit --tag gcr.io/$GCE_PROJECT/go-werewolf:latest $GO_ROOT
gcloud compute instances reset $GCE_INSTANCE
