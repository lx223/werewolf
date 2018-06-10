#!/bin/bash
set -e

REPO_BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

PROTO_ROOT="${REPO_BASE}/protos"
GO_ROOT="${REPO_BASE}/server/src/generated"

# Clear Go generated code
rm -rf $GO_ROOT/*

protoc -I=$PROTO_ROOT --go_out=$GO_ROOT $PROTO_ROOT/*.proto