#!/bin/bash

set -e

VERSION="0.0.4"
COMMIT_SHA=$(git rev-parse HEAD 2>/dev/null)
COMMIT_AUTHOR=$(git log -1 --pretty=format:"%an" 2>/dev/null)
REPOSITORY="https://github.com/sharavara/ping"
IMAGE_NAME="sharavara/ping"
PLATFORMS="linux/amd64,linux/arm64"
PUSH=${1:-false}

echo "Building API service"
echo "Version: $VERSION"
echo "Commit SHA: $COMMIT_SHA"
echo "Commit Author: $COMMIT_AUTHOR"
echo "Repository: $REPOSITORY"
echo "Image: $IMAGE_NAME:$VERSION"
echo "Platforms: $PLATFORMS"
echo "Push: $PUSH"

docker buildx create --use --name ping-builder || true

BUILD_CMD="docker buildx build --platform $PLATFORMS \
  --build-arg VERSION=$VERSION \
  --build-arg COMMIT_SHA=$COMMIT_SHA \
  --build-arg IMAGE_NAME=$IMAGE_NAME \
  --build-arg REPOSITORY=$REPOSITORY \
  --build-arg COMMIT_AUTHOR='$COMMIT_AUTHOR' \
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