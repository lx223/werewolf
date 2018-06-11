#!/bin/bash
set -e

REPO_BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROTO_ROOT="${REPO_BASE}/proto"
GO_OUT="${REPO_BASE}/go/src/server/generated"

# Clear Go generated code
rm -rf $GO_OUT/*

for p in `find $PROTO_ROOT -name "*.proto" -type f`; do
    echo "Generating # $p"
    protoc -I$PROTO_ROOT --go_out=plugins=grpc:$GO_OUT $p
done