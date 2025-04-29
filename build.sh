#!/bin/bash

set -e

VERSION="0.1.0"
#COMMIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "dev")
COMMIT_SHA=$(git rev-parse HEAD 2>/dev/null)
IMAGE_NAME="sharavara/ping"
PLATFORMS="linux/amd64,linux/arm64"
PUSH=${1:-false}

echo "Building ping API service"
echo "Version: $VERSION"
echo "Commit SHA: $COMMIT_SHA"
echo "Image: $IMAGE_NAME:$VERSION"
echo "Platforms: $PLATFORMS"
echo "Push: $PUSH"

docker buildx create --use --name ping-builder || true

BUILD_CMD="docker buildx build --platform $PLATFORMS \
  --build-arg VERSION=$VERSION \
  --build-arg COMMIT_SHA=$COMMIT_SHA \
  -t $IMAGE_NAME:$VERSION \
  -t $IMAGE_NAME:latest"

if [ "$PUSH" == "true" ]; then
  BUILD_CMD="$BUILD_CMD --push"
else
  BUILD_CMD="$BUILD_CMD --load"
fi

BUILD_CMD="$BUILD_CMD ."
echo $BUILD_CMD

eval $BUILD_CMD

echo "Build complete!"