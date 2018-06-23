#!/bin/bash
set -e

REPO_BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPTS_ROOT="${REPO_BASE}/scripts"
PROTO_ROOT="${REPO_BASE}/proto"
GO_ROOT="${REPO_BASE}/go/src/"
DEPLOY_YAML_ROOT="${REPO_BASE}/resources/deploy"

$SCRIPTS_ROOT/codegen.sh
gcloud endpoints services deploy $PROTO_ROOT/out.pb $DEPLOY_YAML_ROOT/endpoint.yaml
gcloud container builds submit --tag gcr.io/trial-194900/go-werewolf:latest $GO_ROOT
kubectl apply -f $DEPLOY_YAML_ROOT/deployment.yaml