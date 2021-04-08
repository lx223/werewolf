#!/bin/bash
set -e

REPO_BASE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROTO_ROOT="${REPO_BASE}/proto"
GO_OUT="${REPO_BASE}/go/server/generated"
SWIFT_OUT="${REPO_BASE}/ios/werewolf-assistant/werewolf-assistant/generated"
JAVA_PROTO_DIR="${REPO_BASE}/android/app/src/main/proto"
WEB_OUT="${REPO_BASE}/react/src/generated"

# Code-gen descriptor
protoc \
    -I$PROTO_ROOT \
    --include_imports \
    --include_source_info \
    --descriptor_set_out=$PROTO_ROOT/out.pb \
    ${PROTO_ROOT}/*.proto

# Code-gen Go files
rm -rf $GO_OUT/*
for p in `find $PROTO_ROOT -name "*.proto" -type f`; do
    protoc -I$PROTO_ROOT --go_out=plugins=grpc:$GO_OUT $p
done
echo "Finished generating Go files"

# Copy *.proto to Android project
rm -rf $JAVA_PROTO_DIR
cp -R $PROTO_ROOT $JAVA_PROTO_DIR
echo "Finished coping proto to Android project"

# Code-gen TS files
pushd $REPO_BASE/react
npm install
popd
rm -rf $WEB_OUT/*
protoc -I$PROTO_ROOT \
    --plugin=protoc-gen-ts=./react/node_modules/.bin/protoc-gen-ts \
    --ts_out=service=true:$WEB_OUT \
    --js_out=import_style=commonjs,binary:$WEB_OUT \
    ${PROTO_ROOT}/*.proto
echo "Finished generating web files"
