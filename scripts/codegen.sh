#!/bin/bash
set -e

REPO_BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROTO_ROOT="${REPO_BASE}/proto"
GO_OUT="${REPO_BASE}/go/src/server/generated"
SWIFT_OUT="${REPO_BASE}/ios/werewolf-assistant/werewolf-assistant/generated"

# Code-gen Go files
rm -rf $GO_OUT/*
for p in `find $PROTO_ROOT -name "*.proto" -type f`; do
    protoc -I$PROTO_ROOT --go_out=plugins=grpc:$GO_OUT $p
done
echo "Finished generating Go files"

# Code-gen Swift files
rm -rf $SWIFT_OUT/*
protoc -I$PROTO_ROOT --swift_out=$SWIFT_OUT --swiftgrpc_out=Server=false:$SWIFT_OUT ${PROTO_ROOT}/**/*.proto
echo "Finished generating Swift files"