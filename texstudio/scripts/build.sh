#!/bin/bash

# $IMAGE_NAME var is injected into the build so the tag is correct.

echo "--build.sh hook called--"
echo "build.sh hook: IMAGE_NAME '$IMAGE_NAME'"
echo "build.sh hook: DOCKERFILE_PATH '$DOCKERFILE_PATH'"
echo "build.sh hook: CACHE_TAG '$CACHE_TAG'"
echo "build.sh hook: DOCKER_TAG '$DOCKER_TAG'"
echo "build.sh hook: DOCKER_REPO '$DOCKER_REPO'"
echo "build.sh hook: SOURCE_BRANCH '$SOURCE_BRANCH'"
echo "build.sh hook: SOURCE_COMMIT '$SOURCE_COMMIT'"

. "$(dirname "$DOCKERFILE_PATH")/env_file_all"
echo "build.sh hook: TEXSTUDIO_VERSION_QT4 '$TEXSTUDIO_VERSION_QT4'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5 '$TEXSTUDIO_VERSION_QT5'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5_DEBIAN9 '$TEXSTUDIO_VERSION_QT5_DEBIAN9'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5_DEBIAN10 '$TEXSTUDIO_VERSION_QT5_DEBIAN10'"

docker build --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
            --build-arg VCS_REF=$(git rev-parse --short HEAD) \
            --build-arg TEXSTUDIO_VERSION_QT4="$TEXSTUDIO_VERSION_QT4" \
            --build-arg TEXSTUDIO_VERSION_QT5="$TEXSTUDIO_VERSION_QT5" \
            --build-arg TEXSTUDIO_VERSION_QT5_DEBIAN9="$TEXSTUDIO_VERSION_QT5_DEBIAN9" \
            --build-arg TEXSTUDIO_VERSION_QT5_DEBIAN10="$TEXSTUDIO_VERSION_QT5_DEBIAN10" \
            -f "$DOCKERFILE_PATH" -t $IMAGE_NAME .

